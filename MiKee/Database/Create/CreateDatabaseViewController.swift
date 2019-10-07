// CreateDatabaseViewController.swift
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
import KeePassKit
import MiKit

protocol CreateDatabaseViewControllerDelegate: class {
    func createDatabaseViewController(_ createDatabaseViewController: CreateDatabaseViewController, didCreate database: Database, tree: KPKTree?)
    func createDatabaseViewControllerDidCancel(_ createDatabaseViewController: CreateDatabaseViewController)
}

class CreateDatabaseViewController: UIViewController {

    var databaseName: String?
    var masterPassword: String?
    var keyFile: String?

    var database: Database?
    var tree: KPKTree?

    weak var delegate: CreateDatabaseViewControllerDelegate?

    @IBOutlet public weak var nextButton: UIButton?
    @IBOutlet public weak var backButton: UIButton?
    @IBOutlet public weak var formBottomConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Asset.background.color

        nextButton?.setTitle(L10n.next, for: .normal)
        nextButton?.setTitleColor(.white, for: .normal)
        nextButton?.backgroundColor = Asset.purple.color

        backButton?.setTitle(L10n.back, for: .normal)
        backButton?.setTitleColor(Asset.purple.color, for: .normal)
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? CreateDatabaseViewController else { return }
        destination.databaseName = databaseName
        destination.masterPassword = masterPassword
        destination.keyFile = keyFile
        destination.database = database
        destination.tree = tree
        destination.delegate = delegate
    }

    @IBAction func next(_ sender: Any) {
        safely { try next() }
    }

    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    func next() throws {
        performSegue(withIdentifier: "next", sender: self)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        let height = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height

        formBottomConstraint?.constant = height
        UIView.animate(withDuration: 0.3, animations: view.layoutIfNeeded)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        formBottomConstraint?.constant = 0
        UIView.animate(withDuration: 0.3, animations: view.layoutIfNeeded)
    }

}

extension CreateDatabaseViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        next(textField)
        return true
    }

}

class DatabaseNameViewController: CreateDatabaseViewController {

    var databases: [String]!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        databases = Database.names()

        titleLabel.text = L10n.databaseName
        titleLabel.textColor = Asset.grey.color
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nameTextField.becomeFirstResponder()
    }

    override func next() throws {
        guard let name = nameTextField.text, !name.isEmpty else {
            throw MiError.message(NSLocalizedString("Please enter a Password Database name.", comment: ""))
        }

        guard !databases.contains(name) else {
            throw MiError.alreadyExist(name)
        }

        databaseName = name
        try super.next()
    }
}

class MasterPasswordViewController: CreateDatabaseViewController {

    @IBOutlet weak var passwordTitleLabel: UILabel!
    @IBOutlet weak var masterPasswordField: UITextField!
    @IBOutlet weak var repeatTitleLabel: UILabel!
    @IBOutlet weak var repeatPasswordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        passwordTitleLabel.text = L10n.masterPassword
        passwordTitleLabel.textColor = Asset.grey.color

        repeatTitleLabel.text = L10n.confirmMasterPassword
        repeatTitleLabel.textColor = Asset.grey.color
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        masterPasswordField.becomeFirstResponder()

        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func next() throws {
        guard let password = masterPasswordField.text, !password.isEmpty else {
            throw MiError.noPasswordValue
        }

        guard let `repeat` = repeatPasswordField.text, password == `repeat` else {
            throw MiError.passwordMismatch
        }

        masterPassword = password
        try super.next()
    }

    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === masterPasswordField {
            return repeatPasswordField.becomeFirstResponder()
        }
        return super.textFieldShouldReturn(textField)
    }

}

class KeyFileViewController: CreateDatabaseViewController, KeysViewControllerDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var orTitleLabel: UILabel!
    @IBOutlet weak var fileTextField: UITextField!
    @IBOutlet weak var selectKeyButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = L10n.createAKeyFile
        titleLabel.textColor = Asset.grey.color

        fileTextField.textColor = Asset.purple.color

        orTitleLabel.text = L10n.or
        orTitleLabel.textColor = Asset.grey.color

        selectKeyButton.setTitle(L10n.selectAnExistingOne, for: .normal)
        selectKeyButton.setTitleColor(.black, for: .normal)
        selectKeyButton.backgroundColor = Asset.largeButtonBackground.color

        nextButton?.setTitle(L10n.skip, for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fileTextField.becomeFirstResponder()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        guard let destination = segue.destination as? KeysViewController else { return }
        destination.delegate = self
    }

    override func next() throws {
        if let text = fileTextField.text, !text.isEmpty {
            keyFile = text
        }

        guard let name = databaseName, let password = masterPassword else {
            throw MiError.unknown
        }

        database = try Database.create(name: name, password: password, key: keyFile)
        Settings.LastDatabaseName = databaseName
        try super.next()
    }

    @IBAction func textFieldDidChange(_ textField: UITextField) {

        let title: String
        if let text = textField.text, !text.isEmpty {
            title = L10n.create
        } else {
            title = L10n.skip
        }
        nextButton?.setTitle(title, for: .normal)
    }

    func keysViewController(_ keysViewController: KeysViewController, didSelect key: Database.Key) {
        fileTextField.text = key.name
        nextButton?.setTitle(L10n.create, for: .normal)
    }

    func keysViewController(_ keysViewController: KeysViewController, didRemoveWith name: String) {
        guard name == fileTextField.text else { return }
        fileTextField.text = nil
        nextButton?.setTitle(L10n.skip, for: .normal)
    }
}

class SuccessViewController: CreateDatabaseViewController, UIDocumentPickerDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = L10n.yourPasswordDatabaseHasBeenCreated
        titleLabel.textColor = Asset.grey.color

        descriptionTextView.text =
            L10n.yourPasswordDatabaseHasBeenSavedLocallyDoYouWantToExportIt +
            "\n\n" +
            L10n.miKeeWillBeAbleToKeepItSyncedWithYourExternalStorage +
            " (iCloud, Dropbox, Google Drive, ...)"
        descriptionTextView.textColor = Asset.grey.color

        nextButton?.setTitle(L10n.export, for: .normal)
        backButton?.setTitle(L10n.skip, for: .normal)

        database?.open {
            self.tree = $0.value
        }
    }

    @IBAction func cloud(_ sender: Any) {
        safely {
            guard let url = try database?.url() else { throw MiError.unknown }
            let browser = UIDocumentPickerViewController(urls: [url], in: .moveToService)
            browser.delegate = self
            present(browser, animated: true)
        }
    }

    @IBAction func skip(_ sender: Any) {
        safely { try next() }
    }

    override func next() throws {
        guard let database = database else { throw MiError.unknown }
        delegate?.createDatabaseViewController(self, didCreate: database, tree: tree)
    }

    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        safely {
            guard let url = urls.first else { throw MiError.copyFile }
            try database?.set(url: url)
            try next()
        }
    }

}
