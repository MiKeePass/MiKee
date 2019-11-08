// FieldAnimationController.swift
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

class FieldAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    var isPresenting = true

    var cell: UITableViewCell

    init(from cell: UITableViewCell) {
        self.cell = cell
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        isPresenting ? present(using: transitionContext) : dismiss(using: transitionContext)
    }

    func present(using transitionContext: UIViewControllerContextTransitioning) {

        guard let destination = transitionContext.viewController(forKey: .to) as? FieldViewController else { return }

        let containerView = transitionContext.containerView

        destination.view.frame = transitionContext.finalFrame(for: destination)
        containerView.addSubview(destination.view)
        containerView.setNeedsLayout()

        destination.backgroundView.alpha = 0
        cell.isHidden = true

        // Animate Appearence
        let topBarConstraint = destination.topView.bottomAnchor.constraint(equalTo: destination.view.topAnchor)
        let topContainerConstraint = destination.contentView.topAnchor.constraint(equalTo: cell.topAnchor)
        let heightContainerConstraint = destination.contentView.heightAnchor.constraint(equalTo: cell.heightAnchor)

        NSLayoutConstraint.activate([topBarConstraint, topContainerConstraint, heightContainerConstraint])
        containerView.layoutIfNeeded()

        NSLayoutConstraint.deactivate([topBarConstraint, topContainerConstraint, heightContainerConstraint])
        containerView.setNeedsLayout()

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            destination.backgroundView.alpha = 1
            containerView.layoutIfNeeded()
        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
    }

    func dismiss(using transitionContext: UIViewControllerContextTransitioning) {

        guard let destination = transitionContext.viewController(forKey: .from) as? FieldViewController else { return }

        let containerView = transitionContext.containerView

        cell.isHidden = true

        // Animate Disappearence
        let topBarConstraint = destination.topView.bottomAnchor.constraint(equalTo: destination.view.topAnchor)
        let topContainerConstraint = destination.contentView.topAnchor.constraint(equalTo: cell.topAnchor)
        let heightContainerConstraint = destination.contentView.heightAnchor.constraint(equalTo: cell.heightAnchor)

        NSLayoutConstraint.activate([topBarConstraint, topContainerConstraint, heightContainerConstraint])
        containerView.setNeedsLayout()

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            destination.backgroundView.alpha = 0
            containerView.layoutIfNeeded()
        }, completion: { _ in
            self.cell.isHidden = false
            transitionContext.completeTransition(true)
        })
    }

}
