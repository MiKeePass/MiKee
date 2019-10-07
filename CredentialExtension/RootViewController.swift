// RootViewController.swift
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

import AuthenticationServices
import Resources
import MiKit
import ExtensionKit
import KeePassKit

class RootViewController: ASCredentialProviderViewController {

    @IBOutlet weak var iconView: UIImageView!

    var openViewController: OpenViewController!

    override func loadView() {
        MiKee.appearance()
        super.loadView()
    }

    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        guard let service = serviceIdentifiers.first, let url = URL(string: service.identifier) else {
            return extensionContext.cancelRequest(withError: ExtensionError.unexpectedData)
        }

        openViewController.credential = Credential(action: .find, url: url)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        iconView.image = Asset.miKee.image

        performSegue(withIdentifier: "open", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let nvc = segue.destination as? UINavigationController,
            let destination = nvc.viewControllers.first as? OpenViewController
        else { return }

        destination.delegate = self
        openViewController = destination
    }

    /*
     Implement this method if your extension supports showing credentials in the QuickType bar.
     When the user selects a credential from your app, this method will be called with the
     ASPasswordCredentialIdentity your app has previously saved to the ASCredentialIdentityStore.
     Provide the password by completing the extension request with the associated ASPasswordCredential.
     If using the credential would require showing custom UI for authenticating the user, cancel
     the request with error code ASExtensionError.userInteractionRequired.

    override func provideCredentialWithoutUserInteraction(for credentialIdentity: ASPasswordCredentialIdentity) {
        let databaseIsUnlocked = true
        if (databaseIsUnlocked) {
            let passwordCredential = ASPasswordCredential(user: "j_appleseed", password: "apple1234")
            self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
        } else {
            self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code:ASExtensionError.userInteractionRequired.rawValue))
        }
    }
    */

    /*
     Implement this method if provideCredentialWithoutUserInteraction(for:) can fail with
     ASExtensionError.userInteractionRequired. In this case, the system may present your extension's
     UI and call this method. Show appropriate UI for authenticating the user then provide the password
     by completing the extension request with the associated ASPasswordCredential.

    override func prepareInterfaceToProvideCredential(for credentialIdentity: ASPasswordCredentialIdentity) {
    }
    */

}

extension RootViewController: OpenViewControllerDelegate {

    func openViewController(_ openViewController: OpenViewController, didSelect credential: Credential) {
        Settings.LastEnterBackgroundDate = Date()

        guard let user = credential.username, let password = credential.password else {
            return extensionContext.cancelRequest(withError: ExtensionError.unexpectedData)
        }

        let passwordCredential = ASPasswordCredential(user: user, password: password)
        extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
    }

    func openViewController(_ openViewController: OpenViewController, didRaise error: Error) {
        extensionContext.cancelRequest(withError: error)
        Settings.LastEnterBackgroundDate = Date()
    }

}
