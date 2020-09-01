// FieldPresentTransitioning.swift
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

class FieldPresentTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

    var cell: UITableViewCell?

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let destination = transitionContext.viewController(forKey: .to) as? FieldViewController else { return }

        let containerView = transitionContext.containerView

        destination.view.frame = transitionContext.finalFrame(for: destination)
        containerView.addSubview(destination.view)
        containerView.setNeedsLayout()

        destination.backgroundView.alpha = 0
        cell?.isHidden = true

        // Animate Appearence
        let constraints: [NSLayoutConstraint]

        if let cell = cell {
            constraints = [
                destination.topView.bottomAnchor.constraint(equalTo: destination.view.topAnchor),
                destination.contentView.topAnchor.constraint(equalTo: cell.topAnchor),
                destination.contentView.heightAnchor.constraint(equalTo: cell.heightAnchor)
            ]

        } else {
            constraints = [
                destination.topView.bottomAnchor.constraint(equalTo: destination.view.topAnchor),
                destination.contentView.bottomAnchor.constraint(equalTo: destination.view.topAnchor)
            ]
        }

        NSLayoutConstraint.activate(constraints)
        containerView.layoutIfNeeded()

        NSLayoutConstraint.deactivate(constraints)
        containerView.setNeedsLayout()

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            destination.backgroundView.alpha = 1
            containerView.layoutIfNeeded()
        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
    }

}

class FieldDismissTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

    var cell: UITableViewCell?

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let destination = transitionContext.viewController(forKey: .from) as? FieldViewController else { return }

        let containerView = transitionContext.containerView

        cell?.isHidden = true

        // Animate Disappearence
        let constraints: [NSLayoutConstraint]

        if let cell = cell {
            constraints = [
                destination.topView.bottomAnchor.constraint(equalTo: destination.view.topAnchor),
                destination.contentView.topAnchor.constraint(equalTo: cell.topAnchor),
                destination.contentView.heightAnchor.constraint(equalTo: cell.heightAnchor)
            ]

        } else {
            constraints = [
                destination.topView.bottomAnchor.constraint(equalTo: destination.view.topAnchor),
                destination.contentView.bottomAnchor.constraint(equalTo: destination.view.topAnchor)
            ]
        }

        NSLayoutConstraint.activate(constraints)
        containerView.setNeedsLayout()

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            destination.backgroundView.alpha = 0
            containerView.layoutIfNeeded()
        }, completion: { _ in
            self.cell?.isHidden = false
            transitionContext.completeTransition(true)
        })
    }

}
