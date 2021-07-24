// ActionSheet.swift
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
import Resources
import ObjectiveC

public protocol Action: AnyObject {

    var control: UIControl { get }

    var action: ((Action) -> Void)? { get set }
}

public class ActionSheet: UIViewController {

    public private(set) var actions = [Action]()

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    private var marginInsets: UIEdgeInsets! {
        didSet {
            leadingConstraint.constant = marginInsets.left
            trailingConstraint.constant = marginInsets.right
            topConstraint.constant =  marginInsets.top
            bottomConstraint.constant = marginInsets.bottom
            view.setNeedsLayout()
        }
    }

    private convenience init() {
        self.init(nibName: String(describing: ActionSheet.self),
                  bundle: Bundle(for: ActionSheet.self))
    }

    public convenience init(actions: [Action]) {
        self.init()
        self.actions = actions
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
        transitioningDelegate = self

        marginInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        contentView.backgroundColor = Asset.background.color

        for (index, action) in actions.enumerated() {

            contentView.addSubview(action.control)
            action.control.translatesAutoresizingMaskIntoConstraints = false

            action.control.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            contentView.trailingAnchor.constraint(equalTo: action.control.trailingAnchor).isActive = true

            if action === actions.first {
                action.control.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            } else {
                let prev = actions[index - 1]
                action.control.topAnchor.constraint(equalTo: prev.control.bottomAnchor).isActive = true
            }

            if action === actions.last {
                contentView.bottomAnchor.constraint(equalTo: action.control.bottomAnchor).isActive = true
            }

            action.control.heightAnchor.constraint(greaterThanOrEqualToConstant: 66).isActive = true

            action.control.addTarget(self, action: #selector(dismiss(sender:)), for: .touchUpInside)
        }
    }

    @objc func dismiss(sender: Any) {

        dismiss(animated: true) {
            if let action = sender as? Action {
                action.action?(action)
            }
            self.actions.removeAll()
        }
    }

}

extension ActionSheet: UIViewControllerTransitioningDelegate {

    public func animationController(forPresented presented: UIViewController,
                                    presenting: UIViewController,
                                    source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentTransition()
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissTransition()
    }

    class Transition: NSObject, UIViewControllerAnimatedTransitioning {

        let duration = 0.3

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
            fatalError("Not implemented")
        }

    }

    class PresentTransition: Transition {

        override func animateTransition(_ from: UIViewController, to: UIViewController, container: UIView, completion: @escaping (Bool) -> Void) {

            to.view.frame = container.bounds
            container.addSubview(to.view)

            guard let actionSheet = to as? ActionSheet else { return }

            let constraint = actionSheet.bottomConstraint
            constraint?.constant = -container.bounds.height

            actionSheet.view.backgroundColor = actionSheet.view.backgroundColor?.withAlphaComponent(0)

            to.view.layoutIfNeeded()
            UIView.animate(withDuration: duration, animations: {
                constraint?.constant = actionSheet.marginInsets.bottom
                actionSheet.view.backgroundColor = actionSheet.view.backgroundColor?.withAlphaComponent(0.4)
                to.view.layoutIfNeeded()
            }, completion: completion)
        }
    }

    class DismissTransition: Transition {

        override func animateTransition(_ from: UIViewController, to: UIViewController, container: UIView, completion: @escaping (Bool) -> Void) {

            container.addSubview(from.view)

            guard let actionSheet = from as? ActionSheet else { return }

            let constraint = actionSheet.bottomConstraint

            UIView.animate(withDuration: duration, animations: {
                constraint?.constant = -container.bounds.height
                actionSheet.view.backgroundColor = actionSheet.view.backgroundColor?.withAlphaComponent(0)
                from.view.layoutIfNeeded()
            }, completion: completion)
        }
    }
}

public class ButtonAction: UIButton, Action {

    public var control: UIControl {
        return self
    }

    public var action: ((Action) -> Void)?

    public convenience init(image: UIImage? = nil, title: String? = nil, handler: (() -> Void)? = nil) {
        self.init()
        setTitle(title, for: .normal)
        setImage(image, for: .normal)
        action = { _ in handler?() }
    }

}

public class SegmentedAction: UISegmentedControl, Action {

    public var control: UIControl {
        return self
    }

    public var action: ((Action) -> Void)?

    public convenience init(items: [Any]?, handler: ((Int) -> Void)? = nil) {
        self.init(items: items)
        action = { handler?( ($0 as! SegmentedAction).selectedSegmentIndex ) }
    }

}
