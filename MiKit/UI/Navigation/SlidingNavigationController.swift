// SlidingNavigationController.swift
// This file is part of MiKee.
//
// Copyright © 2019 Maxime Epain. All rights reserved.
//
// MiKee is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// MiKee is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with MiKee. If not, see <https://www.gnu.org/licenses/>.

import UIKit

open class SlidingNavigationController: UINavigationController, UINavigationControllerDelegate {

    public enum Direction {
        case top
        case left
        case bottom
        case right
    }

    @IBInspectable public var transitionDuration: Double = 0.3

    var animators = [UIViewController : (push: Animator, pop: Animator)]()

    open override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
    }

    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let animator = animationController as? Animator, animator.interaction.isInteracting else {
            return nil
        }
        return animator.interaction
    }

    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        if let translationController = navigationController as? SlidingNavigationController {

            switch operation {
            case .pop: return translationController.animators[fromVC]?.pop
            case .push: return translationController.animators[toVC]?.push
            default: return nil
            }
        }

        return nil
    }

    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        self.pushViewController(viewController, direction: .right, animated: animated)
    }

    open func pushViewController(_ viewController: UIViewController, direction: Direction, animated: Bool) {

        let push: Animator!
        let pop: Animator!

        switch direction {

        case .top:
            push = Animator(controller: self, direction: .top)
            pop = Animator(controller: self, direction: .bottom)

        case .right:
            push = Animator(controller: self, direction: .right)
            pop = Animator(controller: self, direction: .left)

        case .bottom:
            push = Animator(controller: self, direction: .bottom)
            pop = Animator(controller: self, direction: .top)

        case .left:
            push = Animator(controller: self, direction: .left)
            pop = Animator(controller: self, direction: .right)
        }

        viewController.view.addGestureRecognizer(pop.interaction.gesture)

        pop.completion = {
            self.animators.removeValue(forKey: viewController)
        }

        animators[viewController] = (push, pop)

        super.pushViewController(viewController, animated: animated)
    }

    open override var interactivePopGestureRecognizer: UIGestureRecognizer? {
        if let viewController = topViewController {
            return animators[viewController]?.pop.interaction.gesture
        }
        return nil
    }

    class Animator: NSObject, UIViewControllerAnimatedTransitioning {

        private(set) weak var controller: SlidingNavigationController!

        let direction: Direction

        let interaction: Interaction!

        var completion: (() -> Void)?

        init(controller: SlidingNavigationController, direction: Direction) {
            self.direction = direction
            self.controller = controller
            self.interaction = Interaction(controller: controller, direction: direction)
        }

        // This is used for percent driven interactive transitions, as well as for
        // container controllers that have companion animations that might need to
        // synchronize with the main animation.
        public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return controller.transitionDuration
        }

        // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
        public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

            guard let to = transitionContext.view(forKey: .to), let from = transitionContext.view(forKey: .from) else {
                return
            }

            transitionContext.containerView.addSubview(to)

            var fromFrame = controller.view.bounds
            var toFrame = controller.view.bounds

            switch direction {

            case .top:
                fromFrame.origin.y = fromFrame.maxY
                toFrame.origin.y = toFrame.minY - toFrame.height

            case .left:
                fromFrame.origin.x = fromFrame.maxX
                toFrame.origin.x = toFrame.minX - toFrame.width

            case .bottom:
                fromFrame.origin.y = fromFrame.minY - fromFrame.height
                toFrame.origin.y = toFrame.maxY

            case .right:
                fromFrame.origin.x = fromFrame.minX - fromFrame.width
                toFrame.origin.x = toFrame.maxX
            }

            to.frame = toFrame
            UIView.animate(withDuration: controller.transitionDuration, delay: 0, options: [.curveEaseOut], animations: {
                to.frame = self.controller.view.bounds
                from.frame = fromFrame
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })

        }

        public func animationEnded(_ transitionCompleted: Bool) {
            if transitionCompleted, let completion = completion {
                completion()
            }
        }

    }

    class Interaction: NSObject, UIViewControllerInteractiveTransitioning, UIGestureRecognizerDelegate {

        private(set) var context: UIViewControllerContextTransitioning?

        private(set) weak var controller: SlidingNavigationController!

        let direction: Direction

        private(set) var isInteracting = false

        let gesture = UIPanGestureRecognizer()

        init(controller: SlidingNavigationController, direction: Direction) {
            self.direction = direction
            self.controller = controller
            super.init()

            gesture.addTarget(self, action: #selector(pan(gesture:)))
            gesture.delegate = self
        }

        public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
            context = transitionContext
        }

        @objc func pan(gesture: UIPanGestureRecognizer) {

            let translation = gesture.translation(in: controller.view)
            let velocity = gesture.velocity(in: controller.view)

            let size = gesture.view!.bounds.size

            let percent: CGFloat!
            let speed: CGFloat!

            switch direction {

            case .top:
                percent = translation.y / size.height
                speed = velocity.y / size.height

            case .left:
                percent = translation.x / size.width
                speed = velocity.x / size.width

            case .bottom:
                percent = -translation.y / size.height
                speed = -velocity.y / size.height

            case .right:
                percent = -translation.x / size.width
                speed = -velocity.x / size.width
            }

            switch gesture.state {
            case .began:
                isInteracting = true
                controller.popViewController(animated: true)

            case .changed:
                update(percent)

            case .ended:
                isInteracting = false

                if percent > 0.5 || speed > 3 {
                    finish()
                } else {
                    cancel()
                }

            default:
                isInteracting = false
                cancel()
            }
        }

        func update(_ percent: CGFloat) {
            guard let to = context?.view(forKey: .to), let from = context?.view(forKey: .from) else {
                return
            }

            context?.containerView.addSubview(to)
            context?.updateInteractiveTransition(percent)

            var frame = controller.view.bounds
            switch direction {

            case .top:
                frame.origin.y = percent * frame.height
                frame.origin.y = max(0, frame.origin.y)
                frame.origin.y = min(frame.origin.y, frame.height)
                from.frame = frame
                frame.origin.y = frame.minY - frame.height
                to.frame = frame

            case .left:
                frame.origin.x = percent * frame.width
                frame.origin.x = max(0, frame.origin.x)
                frame.origin.x = min(frame.origin.x, frame.width)
                from.frame = frame
                frame.origin.x = frame.minX - frame.width
                to.frame = frame

            case .bottom:
                frame.origin.y = -percent * frame.height
                frame.origin.y = max(-frame.height, frame.origin.y)
                frame.origin.y = min(frame.origin.y, 0)
                from.frame = frame
                frame.origin.y = frame.maxY
                to.frame = frame

            case .right:
                frame.origin.x = -percent * frame.width
                frame.origin.x = max(-frame.width, frame.origin.x)
                frame.origin.x = min(frame.origin.x, 0)
                from.frame = frame
                frame.origin.x = frame.maxX
                to.frame = frame
            }
        }

        func finish() {
            guard let to = context?.view(forKey: .to), let from = context?.view(forKey: .from) else {
                return
            }

            var frame = controller.view.bounds
            switch direction {
            case .top:  frame.origin.y = frame.maxY
            case .left: frame.origin.x = frame.maxX
            case .bottom: frame.origin.y = frame.minY - frame.height
            case .right: frame.origin.x = frame.minX - frame.width
            }

            context?.finishInteractiveTransition()
            UIView.animate(withDuration: controller.transitionDuration, delay: 0, options: [.curveEaseOut], animations: {
                to.frame = self.controller.view.bounds
                from.frame = frame
            }, completion: { _ in
                self.context?.completeTransition(true)
            })
        }

        func cancel() {
            guard let to = context?.view(forKey: .to), let from = context?.view(forKey: .from) else {
                return
            }

            var frame = controller.view.bounds
            switch direction {
            case .top: frame.origin.y = frame.minY - frame.height
            case .left: frame.origin.x = frame.minX - frame.width
            case .bottom: frame.origin.y = frame.maxY
            case .right: frame.origin.x = frame.maxX
            }

            context?.cancelInteractiveTransition()
            UIView.animate(withDuration: controller.transitionDuration, delay: 0, options: [.curveEaseOut], animations: {
                to.frame = frame
                from.frame = self.controller.view.bounds
            }, completion: { _ in
                self.context?.completeTransition(false)
            })
        }

        // MARK: Gesture Recognizer Delegate

        public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let gesture = gestureRecognizer as? UIPanGestureRecognizer else {
                return false
            }

            let translation = gesture.translation(in: controller.view)

            switch direction {
            case .top: return translation.y > 0
            case .left: return translation.x > 0
            case .bottom: return translation.y < 0
            case .right: return translation.x < 0
            }
        }

        public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {

            guard let scrollView = otherGestureRecognizer.view as? UIScrollView else { return false }

            switch direction {
            case .top:
                if scrollView.contentOffset.y > scrollView.contentInset.top,
                    scrollView.contentSize.height > scrollView.frame.height {
                    return false
                }
            case .left:
                if scrollView.contentOffset.x > scrollView.contentInset.left,
                    scrollView.contentSize.width > scrollView.frame.width {
                    return false
                }
            case .bottom: return false
            case .right: return false
            }

            return true
        }
    }

}

public class SlidingRightSegue: UIStoryboardSegue {

    public override func perform() {

        if let translationController = source.navigationController as? SlidingNavigationController {
            translationController.pushViewController(destination, direction: .right, animated: true)
        } else {
            super.perform()
        }
    }
}

public class SlidingLeftSegue: UIStoryboardSegue {

    public override func perform() {

        if let translationController = source.navigationController as? SlidingNavigationController {
            translationController.pushViewController(destination, direction: .left, animated: true)
        } else {
            super.perform()
        }
    }
}

public class SlidingTopSegue: UIStoryboardSegue {

    public override func perform() {

        if let translationController = source.navigationController as? SlidingNavigationController {
            translationController.pushViewController(destination, direction: .top, animated: true)
        } else {
            super.perform()
        }
    }
}

public class SlidingBottomSegue: UIStoryboardSegue {

    public override func perform() {

        if let translationController = source.navigationController as? SlidingNavigationController {
            translationController.pushViewController(destination, direction: .bottom, animated: true)
        } else {
            super.perform()
        }
    }
}
