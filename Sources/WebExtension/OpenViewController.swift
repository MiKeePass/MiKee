// OpenViewController.swift
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
import ExtensionKit
import KeePassKit

class OpenViewController: LockViewController {

    @IBOutlet weak var closeButton: UIButton!

    var tree: KPKTree?

    var credential: Credential!

    override func loadView() {
        MiKee.appearance()
        super.loadView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        closeButton.setImage(Asset.close.image, for: .normal)

        guard
            let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
            let provider = extensionItem.attachments?.first
        else {
            extensionContext?.cancelRequest(withError: ExtensionError.failedToLoadItemProviderData)
            return
        }

        provider.load {
            do {
                self.credential = try $0.unwrap()
            } catch {
                self.extensionContext?.cancelRequest(withError: error)
            }
        }
    }

    override func open(tree: KPKTree, animated: Bool, completion: (() -> Void)? = nil) {
        self.tree = tree

        let storyboard: UIStoryboard

        let bundle = Bundle(identifier: "me.maxep.ExtensionKit")

        switch credential.action {
        case .find, .safari, .chrome:
            storyboard = UIStoryboard(name: "Select", bundle: bundle)
        default:
            storyboard = UIStoryboard(name: "Edit", bundle: bundle)
        }

        guard let nvc = storyboard.instantiateInitialViewController() as? UINavigationController else { return }
        nvc.modalPresentationStyle = .fullScreen
        nvc.transitioningDelegate = self

        if let destination = nvc.viewControllers.first as? EditEntryViewController {
            destination.delegate = self

            if let entry = entry(for: credential) {
                credential.oldPassword = entry.password
                entry.password = credential.password
                destination.entry = entry

            } else {

                let entry = KPKEntry()
                entry.title = credential.title
                entry.url = credential.url.absoluteString
                entry.username = credential.username
                entry.password = credential.password
                entry.notes = credential.notes

                credential.fields?.forEach {
                    let attribute = KPKAttribute(key: $0, value: $1)
                    entry.addCustomAttribute(attribute)
                }

                destination.entry = entry

            }

        } else if let destination = nvc.viewControllers.first as? EntriesViewController {
            destination.credential = credential
            destination.root = tree.root
            destination.delegate = self
        }

        present(nvc, animated: animated, completion: completion)
    }

    @IBAction func selectDatabase(_ sender: Any) {
        performSegue(withIdentifier: "db", sender: self)
    }

    @IBAction func done(_ sender: Any) {
        extensionContext?.cancelRequest(withError: ExtensionError.cancelledByUser)
    }

    func entry(for credential: Credential) -> KPKEntry? {
        guard let root = tree?.root else { return nil }

        if let title = credential.title {
            let predicate = NSPredicate(format: "title ==[c] %@", title)

            let entries = root.childEntries.filter { predicate.evaluate(with: $0) }
            if !entries.isEmpty {
                return entries.first
            }
        }

        guard let host = credential.url.host else { return nil }

        let predicate = NSPredicate(format: "title CONTAINS[c] %@ OR url CONTAINS[c] %@ ", host, host)
        return root.childEntries.filter { predicate.evaluate(with: $0) }.first
    }

}

extension OpenViewController: ExtensionDelegate {

    func viewController(_ viewController: UIViewController, didSelect entry: KPKEntry) {

        if let root = tree?.root, entry.parent == nil {
            entry.move(to: root)
        }

        credential.username = entry.username
        credential.password = entry.password

        // TODO: add OTP

        credential?.fields = [String : String]()
        for attribute in entry.customAttributes {
            credential.fields?[attribute.key] = attribute.value
        }

        try? database?.save()
        extensionContext?.completeRequest(returningCredential: credential)

        Settings.LastEnterBackgroundDate = Date()
    }

    func viewController(didCancel viewController: UIViewController) {
        extensionContext?.cancelRequest(withError: ExtensionError.cancelledByUser)
        Settings.LastEnterBackgroundDate = Date()
    }

    func viewController(_ viewController: UIViewController, didRaise error: Error) {
        extensionContext?.cancelRequest(withError: error)
        Settings.LastEnterBackgroundDate = Date()
    }

}
