// Banner.swift
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

open class Banner: NSObject, UIBarPositioning {

    public var barPosition = UIBarPosition.topAttached

    @IBOutlet var view: UIView!

    @IBOutlet var contentView: UIView!

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var detailTextLabel: UILabel?

    @IBOutlet weak var actionButton: UIButton!

    var backgroundColor: UIColor? {
        get { return view.backgroundColor }
        set { view.backgroundColor = newValue }
    }

    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }

    var detailText: String? {
        get { return detailTextLabel?.text }
        set { detailTextLabel?.text = newValue }
    }

    var animationDuration: TimeInterval = 0.3

    var hideDelay: TimeInterval = 3

    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init()
        if let nibName = nibNameOrNil {
            let nib = UINib(nibName: nibName, bundle: nibBundleOrNil)
            nib.instantiate(withOwner: self, options: nil)
        }

        title = nil
        detailText = nil
    }

    @IBAction func action(_ sender: Any) {
        hide()
    }

    fileprivate weak var parent: UIView?

    public func show(animated: Bool = true) {
        guard let view = UIApplication.topViewController?.view else { return }
        show(in: view, animated: animated)
    }

    public func show(in view: UIView, animated: Bool = true) {
        guard parent == nil else { return }

        parent = view
        view.addSubview(self.view)

        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        self.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true

        switch barPosition {
        case .top, .any:

            self.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true

            let constraint = contentView.topAnchor.constraint(equalTo: self.view.topAnchor)
            constraint.priority = .defaultHigh
            constraint.isActive = true

            contentView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        case .topAttached:

            self.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true

            let constraint = self.contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
            constraint.priority = .defaultHigh

            constraint.isActive = true
            contentView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        case .bottom:

            self.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

            contentView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            let constraint = contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            constraint.priority = .defaultHigh
            constraint.isActive = true

        default: break

        }

        let constraint = self.view.heightAnchor.constraint(equalToConstant: 0)
        constraint.isActive = true
        view.layoutIfNeeded()

        constraint.isActive = false
        let animations = { view.layoutIfNeeded() }

        DispatchQueue.main.asyncAfter(deadline: .now() + hideDelay) {
            self.hide(animated: animated)
        }

        if animated {
            UIView.animate(withDuration: animationDuration, animations: animations)
        } else {
            animations()
        }
    }

    public func hide(animated: Bool = true) {
        guard let parent = parent else { return }

        self.parent = nil

        view.heightAnchor.constraint(equalToConstant: 0).isActive = true

        let animations = { parent.layoutIfNeeded() }

        let completion = { (finished: Bool) in
            self.view.removeFromSuperview()
        }

        if animated {
            UIView.animate(withDuration: animationDuration, animations: animations, completion: completion)
        } else {
            animations()
            completion(true)
        }

    }

}

extension UIViewController {

    public func present(banner: Banner, animated: Bool = true) {
        banner.show(in: view, animated: animated)
    }

}

extension UIApplication {

    static var topViewController: UIViewController? {
        guard let base = UIApplication.shared.keyWindow?.rootViewController else {
            return nil
        }
        return topViewController(base: base)
    }

    private class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }

        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }

        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
