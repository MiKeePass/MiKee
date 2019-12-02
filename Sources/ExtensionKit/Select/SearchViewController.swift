// SearchViewController.swift
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
import MiKit
import KeePassKit

class SearchViewController: UIViewController {

    private var animationController: SearchAnimationController?

    weak var delegate: ExtensionDelegate?

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

    private var entries: [KPKEntry]? {
        didSet { tableView?.reloadData() }
    }

    var searchableEntries: [KPKEntry]? {
        didSet { entries = searchableEntries?.filter(searchBar?.text) }
    }

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.backgroundColor = Asset.background.color

        searchBar.tintColor = Asset.purple.color
        tableView.tableFooterView = UIView()

        tableView.register(EntryCell.nib, forCellReuseIdentifier: "entry")

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.becomeFirstResponder()
        searchBar.setShowsCancelButton(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }

    // MARK: - Keyboard

    @objc func keyboardWillShow(notification: Notification) {
        if let rect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset.bottom = rect.height
            tableView.scrollIndicatorInsets.bottom = rect.height
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.2, animations: {
            self.tableView.contentInset.bottom = 0
            self.tableView.scrollIndicatorInsets.bottom = 0
        })
    }
}

extension SearchViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        entries = searchableEntries?.filter(searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        dismiss(animated: true, completion: nil)
    }

}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entry")! as! EntryCell
        cell.set(entry: entries?[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let entry = entries?[indexPath.row] else { return }

        guard let token = entry.token else {
            delegate?.viewController(self, didSelect: entry)
            return
        }

        let alert = OTPAlertViewController(token: token) {
            self.delegate?.viewController(self, didSelect: entry)
        }

        present(alert, animated: true)
    }
}

extension SearchViewController: UIViewControllerTransitioningDelegate {

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
            let source = transitionContext.viewController(forKey: .from) as? EntriesViewController,
            let destination = transitionContext.viewController(forKey: .to) as? SearchViewController
        else { return }

        let containerView = transitionContext.containerView
        destination.view.frame = containerView.bounds
        containerView.addSubview(destination.view)
        destination.view.layoutIfNeeded()

        destination.backgroundView.alpha = 0
        destination.searchBar.frame = frame(destination: destination, searchBar: source.searchBar)
        destination.view.setNeedsLayout()

        source.searchBar.isHidden = true

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {

            destination.backgroundView.alpha = 1
            destination.view.layoutIfNeeded()

        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
    }

    func dismiss(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let source = transitionContext.viewController(forKey: .to) as? EntriesViewController,
            let destination = transitionContext.viewController(forKey: .from) as? SearchViewController
        else { return }

        source.searchBar.isHidden = true

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {

            destination.backgroundView.alpha = 0
            destination.searchBar.frame = self.frame(destination: destination, searchBar: source.searchBar)

        }, completion: { _ in
            source.searchBar.isHidden = false
            transitionContext.completeTransition(true)
        })
    }

    func frame(destination: SearchViewController, searchBar: UISearchBar) -> CGRect {
        return destination.view.convert(searchBar.frame, from: destination.view)
    }

}

// MARK: - Entry Filter

extension Array where Element == KPKEntry {

    public func filter(_ text: String?) -> [KPKEntry] {
        guard let text = text else { return self }
        if text.isEmpty { return self }

        let title = NSPredicate(format: "title CONTAINS[c] %@", text)
        let url = NSPredicate(format: "url CONTAINS[c] %@", text)
        let values = NSPredicate(format: "SUBQUERY(attributes, $a, $a.protect == NO AND $a.value CONTAINS[c] %@).@count > 0", text)
        let tags = NSPredicate(format: "ANY tags CONTAINS[c] %@", text)
        let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [title, url, values, tags])

        return filter { predicate.evaluate(with: $0) }
    }

}
