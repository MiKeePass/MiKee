// SearchNavigationController.swift
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
import MiKit

class SearchNavigationController: SlidingNavigationController {

    private var animationController: SearchAnimationController?

    weak var searchBar: UISearchBar?

    var searchViewController: SearchViewController? {
        return viewControllers.first as? SearchViewController
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    func initialize() {
        // Handle transition presentation
        modalPresentationStyle = .overCurrentContext
        transitioningDelegate = self
    }

}

extension SearchNavigationController: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        animationController = SearchAnimationController()
        return animationController
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationController?.isPresenting = false
        return animationController
    }
}

class SearchAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    var isPresenting = true

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        if isPresenting {
            present(using: transitionContext)
        } else {
            dismiss(using: transitionContext)
        }
    }

    func present(using transitionContext: UIViewControllerContextTransitioning) {

        guard
            let snc = transitionContext.viewController(forKey: .to) as? SearchNavigationController,
            let destination = snc.searchViewController
        else { return }

        let containerView = transitionContext.containerView
        snc.view.frame = containerView.bounds
        containerView.addSubview(snc.view)
        destination.view.layoutIfNeeded()

        destination.backgroundView.alpha = 0
        destination.searchBar.frame = frame(destination: destination, searchBar: snc.searchBar)
        destination.searchBar.frame.origin.y -= snc.view.safeAreaInsets.top // Cope with the navigation controller top guide
        destination.searchBar.layoutIfNeeded()

        snc.searchBar?.isHidden = true

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {

            destination.backgroundView.alpha = 1
            destination.view.layoutIfNeeded()

        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
    }

    func dismiss(using transitionContext: UIViewControllerContextTransitioning) {
        guard let snc = transitionContext.viewController(forKey: .from) as? SearchNavigationController else { return }
        guard let destination = snc.searchViewController else { return }

        snc.searchBar?.isHidden = true

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {

            destination.backgroundView.alpha = 0
            destination.searchBar.frame = self.frame(destination: destination, searchBar: snc.searchBar)

        }, completion: { _ in
            snc.searchBar?.isHidden = false
            transitionContext.completeTransition(true)
        })
    }

    func frame(destination: SearchViewController, searchBar: UISearchBar?) -> CGRect {
        if let searchBar = searchBar {
            return destination.view.convert(searchBar.frame, from: destination.view)
        }

        var frame = destination.searchBar.frame
        frame.origin.y = -frame.height
        return frame
    }

}
