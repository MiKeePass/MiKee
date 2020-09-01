// CoreServices.swift
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

import Foundation
import MobileCoreServices
import MiKit
import ExtensionKit

public let MKAppURLScheme = "org-appextension-feature-password-management"

// App Extension Actions
public let kUTTypeChromeExtensionAction = "org.appextension.chrome-password-action"
public let kUTTypeAppExtensionFindLoginAction = "org.appextension.find-login-action"
public let kUTTypeAppExtensionSaveLoginAction = "org.appextension.save-login-action"
public let kUTTypeAppExtensionChangePasswordAction = "org.appextension.change-password-action"
public let kUTTypeAppExtensionFillWebViewAction = "org.appextension.fill-webview-action"
public let kUTTypeAppExtensionFillBrowserAction = "org.appextension.fill-browser-action"

struct MKAppExtension {
    static let SplitViewController = "SplitViewController"
    static let VersionNumberKey = "version_number"
    static let URLStringKey = "url_string"
    static let UsernameKey = "username"
    static let PasswordKey = "password"
    static let TOTPKey = "totp"
    static let TitleKey = "login_title"
    static let NotesKey = "notes"
    static let SectionTitleKey = "section_title"
    static let FieldsKey = "fields"
    static let ReturnedFieldsKey = "returned_fields"
    static let OldPasswordKey = "old_password"
    static let PasswordOptionsKey = "password_generator_options"

    struct PasswordOptions {
        static let MinLengthKey = "password_min_length"
        static let MaxLengthKey = "password_max_length"
        static let RequireDigitsKey = "password_require_digits"
        static let RequireSymbolsKey = "password_require_symbols"
        static let ForbiddenCharactersKey = "password_forbidden_characters"
    }
}

// Safari
struct MKExtensionJavaScriptPreprocessing {
    static let URLKey = "MKExtensionJavaScriptPreprocessingURLKey"
    static let UsernameKey = "MKExtensionJavaScriptPreprocessingUsernameKey"
    static let PasswordKey = "MKExtensionJavaScriptPreprocessingPasswordKey"
    static let ErrorKey = "MKExtensionJavaScriptPreprocessingErrorKey"
}

// Chrome
struct MKChromeExtension {
    static let URLStringKey = MKAppExtension.URLStringKey
    static let UsernameKey = MKAppExtension.UsernameKey
    static let PasswordKey = MKAppExtension.PasswordKey
}

extension NSExtensionContext {

    func completeRequest(returningCredential credential: Credential, completionHandler: ((Bool) -> Swift.Void)? = nil) {
        var item = [String: Any]()

        switch credential.action {
        case .chrome:
            item[MKChromeExtension.UsernameKey] = credential.username
            item[MKChromeExtension.PasswordKey] = credential.password

        case .safari:
            var results = [String : String]()
            results[MKExtensionJavaScriptPreprocessing.UsernameKey] = credential.username
            results[MKExtensionJavaScriptPreprocessing.PasswordKey] = credential.password
            item[NSExtensionJavaScriptFinalizeArgumentKey] = results

        case .find:
            item[MKAppExtension.UsernameKey] = credential.username
            item[MKAppExtension.PasswordKey] = credential.password
            item[MKAppExtension.TOTPKey] = credential.totp

        case .save:
            item[MKAppExtension.UsernameKey] = credential.username
            item[MKAppExtension.PasswordKey] = credential.password
            item[MKAppExtension.ReturnedFieldsKey] = credential.fields

        case .change:
            item[MKAppExtension.UsernameKey] = credential.username
            item[MKAppExtension.PasswordKey] = credential.password
            item[MKAppExtension.OldPasswordKey] = credential.oldPassword
            item[MKAppExtension.ReturnedFieldsKey] = credential.fields

        }

        let extensionItem = NSExtensionItem()
        extensionItem.attachments = [ NSItemProvider(item: item as NSSecureCoding, typeIdentifier: kUTTypePropertyList as String)]

        Settings.LastEnterBackgroundDate = Date()

        // Send them back to the javascript processor
        completeRequest(returningItems: [extensionItem], completionHandler: completionHandler)
    }

    func cancelRequest(_ error: Error) {
        Settings.LastEnterBackgroundDate = Date()
        cancelRequest(withError: error)
    }
}

extension NSItemProvider {

    typealias CredentialHandler = (Result<Credential>) -> Void

    func load(_ completionHandler: NSItemProvider.CredentialHandler? = nil) {

        if hasItemConformingToTypeIdentifier(kUTTypeAppExtensionFindLoginAction) {
            return loadFindAction(completionHandler)
        }

        if hasItemConformingToTypeIdentifier(kUTTypeAppExtensionSaveLoginAction) {
            return loadSaveAction(completionHandler)
        }

        if hasItemConformingToTypeIdentifier(kUTTypeAppExtensionChangePasswordAction) {
            return loadChangeAction(completionHandler)
        }

        if hasItemConformingToTypeIdentifier(kUTTypeChromeExtensionAction) {
            return loadChrome(completionHandler)
        }

        if hasItemConformingToTypeIdentifier(kUTTypePropertyList as String) {
            return loadSafari(completionHandler)
        }

    }

    func loadChrome(_ completionHandler: NSItemProvider.CredentialHandler? = nil) {

        loadItem(forTypeIdentifier: kUTTypeChromeExtensionAction, options: nil) { (item, error) in

            completionHandler?( Result {

                if let error = error { throw error }

                guard let item = item as? [String: Any],
                    let str = item[MKChromeExtension.URLStringKey] as? String,
                    let url = URL(string: str)
                    else { throw ExtensionError.failedToLoadItemProviderData }

                return Credential(action: .chrome, url: url)
            })
        }
    }

    func loadSafari(_ completionHandler: NSItemProvider.CredentialHandler? = nil) {

        loadItem(forTypeIdentifier: kUTTypePropertyList as String, options: nil) { (item, error) in

            completionHandler?( Result {

                if let error = error { throw error }

                guard let item = item as? [String: Any],
                    let results = item[NSExtensionJavaScriptPreprocessingResultsKey] as? [String: Any],
                    let str = results[MKExtensionJavaScriptPreprocessing.URLKey] as? String,
                    let url = URL(string: str)
                    else { throw ExtensionError.failedToLoadItemProviderData }

                var cred = Credential(action: .safari, url: url)
                cred.username = results[MKExtensionJavaScriptPreprocessing.UsernameKey] as? String
                cred.password = results[MKExtensionJavaScriptPreprocessing.PasswordKey] as? String
                return cred
            })
        }
    }

    func loadFindAction(_ completionHandler: NSItemProvider.CredentialHandler? = nil) {

        loadItem(forTypeIdentifier: kUTTypeAppExtensionFindLoginAction, options: nil) { (item, error) in

            completionHandler?( Result {

                if let error = error { throw error }

                guard let item = item as? [String: Any],
                    let str = item[MKChromeExtension.URLStringKey] as? String,
                    let url = URL(string: str)
                    else { throw ExtensionError.failedToLoadItemProviderData }

                return Credential(action: .find, url: url)
            })
        }
    }

    func loadSaveAction(_ completionHandler: NSItemProvider.CredentialHandler? = nil) {

        loadItem(forTypeIdentifier: kUTTypeAppExtensionSaveLoginAction, options: nil) { (item, error) in

            completionHandler?( Result {

                if let error = error { throw error }

                guard let item = item as? [String: Any],
                    let str = item[MKChromeExtension.URLStringKey] as? String,
                    let url = URL(string: str)
                    else { throw ExtensionError.failedToLoadItemProviderData }

                var cred = Credential(action: .save, url: url)
                cred.title = item[MKAppExtension.TitleKey] as? String
                cred.username = item[MKAppExtension.UsernameKey] as? String
                cred.notes = item[MKAppExtension.NotesKey] as? String
                cred.fields = item[MKAppExtension.FieldsKey] as? [String: String]

                if let options = item[MKAppExtension.PasswordOptionsKey] as? [String: Any] {
                    cred.passwordOptions = Credential.PasswordOptions(options: options)
                }

                if let password = item[MKAppExtension.PasswordKey] as? String, !password.isEmpty {
                    cred.password = password
                } else {
                    cred.password = cred.passwordOptions.generate()
                }

                return cred
            })
        }
    }

    func loadChangeAction(_ completionHandler: NSItemProvider.CredentialHandler? = nil) {

        loadItem(forTypeIdentifier: kUTTypeAppExtensionChangePasswordAction, options: nil) { (item, error) in

            completionHandler?( Result {

                if let error = error { throw error }

                guard let item = item as? [String: Any],
                    let str = item[MKChromeExtension.URLStringKey] as? String,
                    let url = URL(string: str)
                    else { throw ExtensionError.failedToLoadItemProviderData }

                var cred = Credential(action: .change, url: url)
                cred.title = item[MKAppExtension.TitleKey] as? String
                cred.username = item[MKAppExtension.UsernameKey] as? String
                cred.oldPassword = item[MKAppExtension.OldPasswordKey] as? String
                cred.notes = item[MKAppExtension.NotesKey] as? String
                cred.fields = item[MKAppExtension.FieldsKey] as? [String: String]

                if let options = item[MKAppExtension.PasswordOptionsKey] as? [String: Any] {
                    cred.passwordOptions = Credential.PasswordOptions(options: options)
                }

                if let password = item[MKAppExtension.PasswordKey] as? String, !password.isEmpty {
                    cred.password = password
                } else {
                    cred.password = cred.passwordOptions.generate()
                }

                return cred
            })
        }
    }

}

extension Credential.PasswordOptions {

    init(options: [String: Any]) {
        self.init()

        if let minLength = options[MKAppExtension.PasswordOptions.MinLengthKey] as? Int {
            self.minLength = max(4, minLength)
        }

        if let maxLength = options[MKAppExtension.PasswordOptions.MaxLengthKey] as? Int {
            self.maxLength = min(50, maxLength)
            self.maxLength = max(minLength, self.maxLength)
        }

        if let digits = options[MKAppExtension.PasswordOptions.RequireDigitsKey] as? Bool {
            self.digits = digits
        }

        if let symbols = options[MKAppExtension.PasswordOptions.RequireSymbolsKey] as? Bool {
            self.symbols = symbols
        }

        if let forbiddenCharacters = options[MKAppExtension.PasswordOptions.ForbiddenCharactersKey] as? String {
            self.forbiddenCharacters = forbiddenCharacters
        }
    }
}
