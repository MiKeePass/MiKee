// AlertViewController.swift
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

open class AlertViewController: UIViewController {

    @IBOutlet var overlayView: UIView!

    @IBOutlet var containerView: UIView!

    @IBOutlet public var contentView: UIView?

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialize()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    open override func loadView() {
        let nib = UINib(nibName: String(describing: AlertViewController.self),
                        bundle: Bundle(for: AlertViewController.self))
        nib.instantiate(withOwner: self)
    }

    private func initialize() {
        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
        transitioningDelegate = self
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        guard let contentView = contentView else { return }

        contentView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(contentView)

        contentView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        contentView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        view.layoutIfNeeded()
    }

}

extension AlertViewController: UIViewControllerTransitioningDelegate {

    public func animationController(forPresented presented: UIViewController,
                                    presenting: UIViewController,
                                    source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentTransition()
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissTransition()
    }

    class Transition: NSObject, UIViewControllerAnimatedTransitioning {

        let duration = 0.1

        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return duration
        }

        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let fromController = transitionContext.viewController(forKey: .from) else {
                return transitionContext.completeTransition(false)
            }

            guard let toController = transitionContext.viewController(forKey: .to) else {
                return transitionContext.completeTransition(false)
            }

            animateTransition(fromController, to: toController, container: transitionContext.containerView) {
                transitionContext.completeTransition($0)
            }
        }

        func animateTransition(_ from: UIViewController, to: UIViewController, container: UIView, completion: @escaping (Bool) -> Void) {
            fatalError("Abstract method")
        }

    }

    class PresentTransition: Transition {

        override func animateTransition(_ from: UIViewController, to: UIViewController, container: UIView, completion: @escaping (Bool) -> Void) {

            to.view.frame = container.bounds
            container.addSubview(to.view)

            guard let controller = to as? AlertViewController else { return }

            controller.overlayView.backgroundColor = .clear
            controller.containerView.layer.transform = CATransform3DMakeScale(0.8, 0.8, 0.8)
            controller.containerView.alpha = 0

            UIView.animate(withDuration: duration, animations: {
                controller.overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
                controller.containerView.layer.transform = CATransform3DIdentity
                controller.containerView.alpha = 1
            }, completion: completion)
        }
    }

    class DismissTransition: Transition {

        override func animateTransition(_ from: UIViewController, to: UIViewController, container: UIView, completion: @escaping (Bool) -> Void) {

            container.addSubview(from.view)

            guard let controller = from as? AlertViewController else { return }

            UIView.animate(withDuration: duration, animations: {
                controller.containerView.alpha = 0
                controller.overlayView.backgroundColor = .clear
            }, completion: completion)
        }
    }
}
