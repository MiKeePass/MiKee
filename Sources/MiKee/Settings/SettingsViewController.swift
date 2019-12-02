// SettingsViewController.swift
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
import Resources
import MiKit
import SafariServices

class SettingsViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!

    @IBOutlet weak var generalLabel: UILabel!

    @IBOutlet weak var biometricContainer: UIView!

    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var privacyButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Asset.background.color

        titleLabel.text = L10n.settings
        backButton.setImage(Asset.forward.image, for: .normal)

        termsButton.setTitle(L10n.termsConditions, for: .normal)
        termsButton.setTitleColor(Asset.purple.color, for: .normal)

        privacyButton.setTitle(L10n.privacyPolicy, for: .normal)
        privacyButton.setTitleColor(Asset.purple.color, for: .normal)

        generalLabel.text = L10n.general

        guard LAContext.biometry == .none else { return }
        biometricContainer.removeFromSuperview()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidBeginEditing(notification:)),
                                               name: UITextField.textDidBeginEditingNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidEndEditing(notification:)),
                                               name: UITextField.textDidEndEditingNotification,
                                               object: nil)

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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: UITextField.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidEndEditingNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.view.translatesAutoresizingMaskIntoConstraints = false
    }

    @IBAction func pop(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @objc func textDidBeginEditing(notification: NSNotification) {
        UIView.animate(withDuration: 0.2, animations: view.layoutIfNeeded)
        guard let textField = notification.object as? UITextField else { return }
        let rect = textField.convert(textField.bounds, to: scrollView)
        scrollView.scrollRectToVisible(rect, animated: true)
    }

    @objc func textDidEndEditing(notification: NSNotification) {
        UIView.animate(withDuration: 0.2, animations: view.layoutIfNeeded)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        let height = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height

        scrollView.contentInset.bottom = height
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
    }

    @IBAction func terms(_ sender: Any) {
        guard let url = URL(string: "https://mikee.maxep.me/terms/") else { return }
        open(url: url)
    }

    @IBAction func privacy(_ sender: Any) {
        guard let url = URL(string: "https://mikee.maxep.me/privacy/") else { return }
        open(url: url)
    }

    private func open(url: URL) {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = true
        configuration.barCollapsingEnabled = false

        let svc = SFSafariViewController(url: url, configuration: configuration)
        svc.preferredBarTintColor = Asset.background.color
        svc.preferredControlTintColor = Asset.purple.color
        svc.dismissButtonStyle = .close
        svc.modalPresentationStyle = .popover
        present(svc, animated: true)
    }

}
