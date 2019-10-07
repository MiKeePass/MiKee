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

    weak var source: EntryViewController?

    init(from source: EntryViewController) {
        self.source = source
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        var cell: UITableViewCell?
        if let key = source?.selectedAttributeKey, let row = source?.availableAttributeKeys.firstIndex(of: key) {
            let indexPath = IndexPath(row: row, section: 0)
            cell = source?.tableView.cellForRow(at: indexPath)
        }

        if isPresenting {
            present(using: transitionContext, from: cell)
        } else {
            dismiss(using: transitionContext, to: cell)
        }
    }

    func present(using transitionContext: UIViewControllerContextTransitioning, from cell: UITableViewCell?) {

        guard let destination = transitionContext.viewController(forKey: .to) as? FieldViewController else { return }

        let containerView = transitionContext.containerView
        destination.view.frame = containerView.bounds
        containerView.addSubview(destination.view)

        destination.backgroundView.alpha = 0
        destination.topView.frame.origin.y = -destination.topView.frame.height
        destination.contentView.frame = frame(destination: destination, cell: cell)
        destination.contentView.layoutIfNeeded()

        cell?.isHidden = true

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {

            destination.backgroundView.alpha = 1
            destination.view.layoutIfNeeded()

        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
    }

    func dismiss(using transitionContext: UIViewControllerContextTransitioning, to cell: UITableViewCell?) {

        guard let destination = transitionContext.viewController(forKey: .from) as? FieldViewController else { return }

        cell?.isHidden = true

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            destination.backgroundView.alpha = 0

            destination.topView.frame.origin.y = -destination.topView.frame.height
            destination.contentView.frame = self.frame(destination: destination, cell: cell)

        }, completion: { _ in

            cell?.isHidden = false
            transitionContext.completeTransition(true)
        })
    }

    func frame(destination: FieldViewController, cell: UITableViewCell?) -> CGRect {
        if let source = source, let cell = cell {
            return destination.view.convert(cell.frame, from: source.tableView)
        }

        var frame = destination.contentView.frame
        frame.origin.y = -frame.height
        return frame
    }

}
