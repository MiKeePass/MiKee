// SettingViewController.swift
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
import LocalAuthentication
import MiKit
import KeePassKit
import Resources

class SettingViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Asset.background.color
    }
}

class NameSettingViewController: SettingViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet var acessoryView: UIToolbar!
    @IBOutlet weak var closeButtonItem: UIBarButtonItem!
    @IBOutlet weak var saveButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel?.text = L10n.databaseName
        titleLabel?.textColor = Asset.grey.color
        nameField.text = Database.current?.tree?.metaData?.databaseName
        nameField.tintColor = Asset.purple.color
        nameField.inputAccessoryView = acessoryView

        closeButtonItem.image = Asset.close.image
        closeButtonItem.tintColor = Asset.lightGrey.color

        saveButtonItem.title = L10n.save
        saveButtonItem.tintColor = Asset.purple.color

        acessoryView.barTintColor = Asset.background.color
    }

    @IBAction func touch(_ sender: Any) {
        nameField.becomeFirstResponder()
    }

    @IBAction func cancel(_ sender: Any) {
        nameField.resignFirstResponder()
    }

    @IBAction func save(_ sender: Any) {
        guard let database = Database.current else { return }
        safely {
            database.tree?.metaData?.databaseName = nameField.text
            try database.save()
            nameField.resignFirstResponder()
        }
    }

}

class PasswordSettingViewController: SettingViewController, UITextFieldDelegate {

    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet var passwordAccessoryView: UIToolbar!
    @IBOutlet weak var passwordCloseButtonItem: UIBarButtonItem!

    @IBOutlet weak var confirmationTitleLabel: UILabel!
    @IBOutlet weak var confirmationField: UITextField!
    @IBOutlet var confirmationAccessoryView: UIToolbar!
    @IBOutlet weak var confirmationCloseButtonItem: UIBarButtonItem!
    @IBOutlet weak var confirmationSaveButtonItem: UIBarButtonItem!

    @IBOutlet weak var activeBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var inactiveBottomConstrain: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel?.text = L10n.masterPassword
        titleLabel?.textColor = Asset.grey.color
        passwordField.text = Database.current?.password
        passwordField.textColor = Asset.purple.color
        passwordField.tintColor = Asset.purple.color
        passwordField.inputAccessoryView = passwordAccessoryView
        passwordCloseButtonItem.image = Asset.close.image
        passwordCloseButtonItem.tintColor = Asset.lightGrey.color

        confirmationTitleLabel.text = L10n.confirmMasterPassword
        confirmationTitleLabel.textColor = Asset.grey.color
        confirmationField.text = nil
        confirmationField.textColor = Asset.purple.color
        confirmationField.tintColor = Asset.purple.color
        confirmationField.inputAccessoryView = confirmationAccessoryView
        confirmationCloseButtonItem.image = Asset.close.image
        confirmationCloseButtonItem.tintColor = Asset.lightGrey.color
        confirmationSaveButtonItem.title = L10n.save
        confirmationSaveButtonItem.tintColor = Asset.purple.color

        passwordAccessoryView.barTintColor = Asset.background.color
        confirmationAccessoryView.barTintColor = Asset.background.color
    }

    @IBAction func touch(_ sender: Any) {
        open()
        passwordField.becomeFirstResponder()
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        open()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField === confirmationField else {
            return confirmationField.becomeFirstResponder()
        }

        close()
        return textField.resignFirstResponder()
    }

    private func open() {
        inactiveBottomConstrain.isActive = false
        activeBottomConstraint.isActive = true
    }

    private func close () {
        activeBottomConstraint.isActive = false
        inactiveBottomConstrain.isActive = true
    }

    @IBAction func cancel(_ sender: Any) {
        close()
        passwordField.resignFirstResponder()
        confirmationField.resignFirstResponder()
        passwordField.text = Database.current?.password
        confirmationField.text = nil
    }

    @IBAction func save(_ sender: Any) {
        guard let database = Database.current else { return }

        safely {
            guard let password = passwordField.text, !password.isEmpty else {
                throw MiError.noPasswordValue
            }

            guard let confirmation = confirmationField.text, password == confirmation else {
                throw MiError.passwordMismatch
            }

            try database.set(password: password)

            close()
            passwordField.resignFirstResponder()
            confirmationField.resignFirstResponder()
        }
    }
}

class KeySettingViewController: SettingViewController, UITextFieldDelegate, KeysViewControllerDelegate {

    @IBOutlet weak var keyField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel?.text = L10n.keyFile
        titleLabel?.textColor = Asset.grey.color
        keyField.placeholder = L10n.selectKeyFile
        keyField.text = Database.current?.key?.name
        keyField.textColor = Asset.purple.color
        keyField.tintColor = Asset.purple.color

        keyField.delegate = self

        keyField.addTarget(self, action: #selector(touch(_:)), for: .add)
        keyField.addTarget(self, action: #selector(remove(_:)), for: .clear)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? KeysViewController else { return }
        destination.delegate = self
    }

    @IBAction func touch(_ sender: Any) {
        performSegue(withIdentifier: "key", sender: sender)
    }

    @objc func remove(_ sender: Any) {
        guard let database = Database.current else { return }

        safely {

            let previousKey = database.key
            try database.set(key: nil)
            keyField.text = nil

            UndoBanner(L10n.updated) {
                try? database.set(key: previousKey)
                self.keyField.text = previousKey?.name
            }.show()
        }
    }

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard textField == keyField else { return true }
        touch(textField)
        return false
    }

    func keysViewController(_ keysViewController: KeysViewController, didSelect key: Database.Key) {
        guard let database = Database.current else { return }

        safely {
            let previousKey = database.key
            try database.set(key: key)
            self.keyField.text = key.name

            UndoBanner(L10n.updated) {
                try? database.set(key: previousKey)
                self.keyField.text = previousKey?.name
            }.show()
        }
    }

    func keysViewController(_ keysViewController: KeysViewController, didRemoveWith name: String) {
        guard name == Database.current?.key?.name else { return }
        remove(keysViewController)
    }
}

class BiometricSettingViewController: SettingViewController {

    @IBOutlet weak var `switch`: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel?.text = LAContext.biometry == .faceID ? L10n.enableFaceID : L10n.enableTouchID
        titleLabel?.textColor = Asset.grey.color
        `switch`.tintColor = Asset.lightGrey.color
        `switch`.onTintColor = Asset.purple.color
        `switch`.isOn = Settings.Biometrics
    }

    @IBAction func toogle(_ sender: UISwitch) {
        Settings.Biometrics = sender.isOn
    }
}

class AutoLockSettingViewController: SettingViewController {

    @IBOutlet weak var valueLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel?.text = L10n.autoLock
        titleLabel?.textColor = Asset.grey.color
        valueLabel?.text = Settings.AutoLock.localized
    }

    @IBAction func autolock(_ sender: Any) {
        var actions = [Action]()

        for autolock in AutoLock.allValues {

            actions.append(title: autolock.localized) {
                self.valueLabel.text = autolock.localized
                Settings.AutoLock = autolock
            }
        }

        let actionSheet = ActionSheet(actions: actions)
        present(actionSheet, animated: true)
    }
}
