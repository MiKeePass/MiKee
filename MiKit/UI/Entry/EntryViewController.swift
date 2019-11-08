// EntryViewController.swift
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
import OneTimePassword
import FontAwesome_swift

open class EntryViewController: UIViewController {

    @IBOutlet public weak var titleField: TitleField!
    @IBOutlet public weak var backButton: UIButton?
    @IBOutlet public weak var addButton: UIButton!
    @IBOutlet public weak var tableView: UITableView!

    public var entry: KPKEntry? {
        didSet { reload() }
    }

    var availableAttributeKeys = [String]()

    var selectedAttributeKey: String?

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Asset.background.color

        titleField.set(entry: entry)
        titleField.addTarget(self, action: #selector(saveTitle(_:)), for: .save)
        titleField.addTarget(self, action: #selector(cancelTitle(_:)), for: .cancel)
        titleField.tintColor = Asset.purple.color
        if let entry = entry, entry.title == nil || entry.title.isEmpty {
            titleField.becomeFirstResponder()
        }

        addButton.setImage(Asset.add.image, for: .normal)
        if let entry = entry {
            addButton.isHidden = !entry.isEditable || entry.isTrashed
        }

        backButton?.setImage(Asset.back.image, for: .normal)

        tableView.register(FieldCell.nib, forCellReuseIdentifier: "field")
        tableView.register(NoteCell.nib, forCellReuseIdentifier: "note")
        tableView.register(BinaryCell.nib, forCellReuseIdentifier: "binary")
        tableView.register(ImageCell.nib, forCellReuseIdentifier: "image")
        tableView.register(OTPCell.nib, forCellReuseIdentifier: "otp")

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(edit(_:)))
        view.addGestureRecognizer(longPress)
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }

    func reload() {
        availableAttributeKeys.removeAll()

        guard let entry = entry else { return }

        for attribute in entry.attributes {

            if  attribute.key == kKPKTitleKey ||
                attribute.value == nil ||
                attribute.value.isEmpty {
                continue
            }

            availableAttributeKeys.append(attribute.key)
        }

        tableView?.reloadData()
    }

    // MARK: - Navigation

    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let destination = segue.destination as? FieldViewController {
            destination.delegate = self

            if let attribute = entry?.attribute(withKey: selectedAttributeKey) {
                destination.attribute = attribute
            } else {
                destination.attribute = KPKAttribute(key: selectedAttributeKey, value: "")
            }

        } else if let destination = segue.destination as? QRScannerController {
            destination.delegate = self
        }

    }

    @IBAction func pop(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Edit

    @objc func edit(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        guard let entry = entry, entry.isEditable && !entry.isTrashed else { return }

        let point = sender.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }

        if indexPath.section == 0 {
            selectedAttributeKey = availableAttributeKeys[indexPath.row]
            performSegue(withIdentifier: "field", sender: self)
        }
    }

    @objc func saveTitle(_ sender: TitleField) {

        defer { sender.resignFirstResponder() }

        guard entry?.iconId != sender.iconId || entry?.title != sender.text else { return }

        safely {
            try Database.current?.write {
                entry?.iconId = sender.iconId
                entry?.title = sender.text
            }
        }

    }

    @objc func cancelTitle(_ sender: TitleField) {
        sender.set(entry: entry)
        sender.resignFirstResponder()
    }

}

extension EntryViewController: UITableViewDelegate, UITableViewDataSource {

    // MARK: Table delegate

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = availableAttributeKeys[indexPath.row]

        switch key {
        case kKPKURLKey:
            guard let value = entry?.url, let url = URL(string: value), UIApplication.shared.canOpenURL(url) else { break }
            UIApplication.shared.open(url)

        default:

            guard let cell = tableView.cellForRow(at: indexPath) else { return }

            if let cell = cell as? OTPCell {
                UIPasteboard.general.string = cell.token?.currentPassword
            } else {
                UIPasteboard.general.string = entry?.valueForAttribute(withKey: key)
            }

            let label = UILabel(frame: cell.bounds)
            label.textAlignment = .center
            label.backgroundColor = Asset.background.color
            label.text = L10n.copied
            cell.addSubview(label)

            UIView.animate(withDuration: 0.3, delay: 0.3, options: [.curveEaseOut], animations: {
                label.alpha = 0
            }, completion: { _ in
                label.removeFromSuperview()
            })
        }
    }

    // MARK: Table data source

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return availableAttributeKeys.count
        }
        return entry?.binaries.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            return self.tableView(tableView, entryCellForRowAt: indexPath.row)
        }
        return self.tableView(tableView, binaryCellForRowAt: indexPath.row)
    }

    private func tableView(_ tableView: UITableView, binaryCellForRowAt index: Int) -> UITableViewCell {

        let binary = entry!.binaries[index]

        if let image = UIImage(data: binary.data) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "image") as! ImageCell
            cell.set(name: binary.name, image: image)
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "binary") as! BinaryCell
        cell.titleLabel?.text = binary.name
        return cell
    }

    private func tableView(_ tableView: UITableView, entryCellForRowAt index: Int) -> UITableViewCell {

        let key = availableAttributeKeys[index]
        let attribute = entry?.attribute(withKey: key)

        if
            let value = attribute?.value,
            let url = URL(string: value),
            let token = Token(url: url)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "otp") as! OTPCell
            cell.titleLabel.text = attribute?.key
            cell.token = token
            return cell
        }

        if
            attribute?.key == TOTPSeedKey,
            let secret = attribute?.value,
            let settings = entry?.attribute(withKey: TOTPSettingsKey)?.value,
            let token = Token(secret: secret, settings: settings)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "otp") as! OTPCell
            cell.titleLabel.text = "TOTP"
            cell.token = token
            return cell
        }

        let cell: FieldCell!
        switch key {
        case kKPKNotesKey:
            cell = tableView.dequeueReusableCell(withIdentifier: "note") as? NoteCell

        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "field") as? FieldCell
        }

        cell.set(attribute: attribute)
        return cell
    }

}

// MARK: Add Entry Attribute

extension EntryViewController {

    @IBAction func add(_ sender: Any) {

        var actions = [Action]()

        if !availableAttributeKeys.contains(kKPKUsernameKey) {

            actions.append(title: L10n.username) {
                self.selectedAttributeKey = kKPKUsernameKey
                self.performSegue(withIdentifier: "field", sender: self)
            }
        }

        if !availableAttributeKeys.contains(kKPKPasswordKey) {

            actions.append(title: L10n.password) {
                self.entry?.attribute(withKey: kKPKPasswordKey).protect = true // Workaround KeePassKit
                self.selectedAttributeKey = kKPKPasswordKey
                self.performSegue(withIdentifier: "field", sender: self)
            }
        }

        if !availableAttributeKeys.contains(kKPKURLKey) {

            actions.append(title: L10n.website) {
                self.selectedAttributeKey = kKPKURLKey
                self.performSegue(withIdentifier: "field", sender: self)
            }
        }

        if !availableAttributeKeys.contains(kKPKNotesKey) {

            actions.append(title: L10n.note) {
                self.selectedAttributeKey = kKPKNotesKey
                self.performSegue(withIdentifier: "field", sender: self)
            }
        }

        actions.append(title: L10n.customField) {
            self.selectedAttributeKey = self.entry?.proposedKey(forAttributeKey: "New Field") ?? "New Field"
            self.performSegue(withIdentifier: "field", sender: self)
        }

        if !isAppExtension {

            actions.append(title: "OTP") {
                self.selectedAttributeKey = self.entry?.proposedKey(forAttributeKey: "OTP") ?? "OTP"
                self.performSegue(withIdentifier: "otp", sender: self)
            }
        }

//        actions.append(icon: .paperclip, title: "Attach File") {
//
//        }
//
//        actions.append(icons: [.pictureO, .camera]) { (index) in
//
//        }

        let actionSheet = ActionSheet(actions: actions)
        present(actionSheet, animated: true)
    }

}

// MARK: Field Edit Delegate

extension EntryViewController: FieldViewControllerDelegate {

    func fieldViewController(_ fieldViewController: FieldViewController, willUpdate attribute: KPKAttribute) {
        Database.current?.beginTransaction()

        if let entry = entry, !entry.hasAttribute(withKey: attribute.key) {
            entry.addCustomAttribute(attribute)
        }

    }

    func fieldViewController(_ fieldViewController: FieldViewController, didUpdate attribute: KPKAttribute) {

        safely { try Database.current?.endTransaction() }

        reload()

        if let row = availableAttributeKeys.firstIndex(of: attribute.key) {
            let indexPath = IndexPath(row: row, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            selectedAttributeKey = attribute.key
        }

    }

    func fieldViewController(_ fieldViewController: FieldViewController, delete attribute: KPKAttribute) {

        safely {
            try Database.current?.write {

                switch attribute.key {

                case kKPKUsernameKey: entry?.username = ""
                case kKPKPasswordKey: entry?.password = ""
                case kKPKURLKey: entry?.url = ""
                case kKPKNotesKey: entry?.notes = ""
                default: entry?.removeCustomAttribute(attribute)
                }
            }

            reload()

            UndoBanner(L10n.deleted) {
                try? Database.current?.undo()
                self.reload()
            }.show()
        }
    }

    func fieldViewController(didDismiss fieldViewController: FieldViewController) {
        selectedAttributeKey = nil
    }

}

// MARK: QR Scanner Delegate

extension EntryViewController: QRScannerControllerDelegate {

    public func scanner(_ scanner: QRScannerController, didFind code: String) {
        guard let entry = entry, let key = selectedAttributeKey else { return }

        safely {
            try Database.current?.write {
                let attribute = KPKAttribute(key: key, value: code)
                entry.addCustomAttribute(attribute)
            }
        }

        reload()
    }

}

// MARK: Title Field Extensions

extension TitleField {

    func set(entry: KPKEntry?) {
        text = entry?.title
        iconId = entry?.iconId ?? 0

        customIcons = entry?.tree?.metaData?.customIcons
        selectedIcon = entry?.icon
    }

}

// MARK: Cells Extensions

extension FieldCell {

    func set(attribute: KPKAttribute?) {

        switch attribute?.key {

        case kKPKUsernameKey?:
            title = L10n.user
            valueField?.canGenerateValue = false
            valueField?.keyboardType = .emailAddress
            isProtected = false

        case kKPKPasswordKey?:
            title = L10n.password
            isProtected = true

        case kKPKURLKey?:
            title = L10n.website
            valueField?.canGenerateValue = false
            valueField?.keyboardType = .URL
            isProtected = false

        case kKPKNotesKey?:
            title = L10n.note
            isProtected = false

        default:
            title = attribute?.key
            isProtected = attribute?.protect ?? false
        }

        value = attribute?.value
        isDefault = attribute?.isDefault() ?? false
    }

}

extension EntryCell {

    public func set(entry: KPKEntry?) {
        if let icon = entry?.icon?.image {
            iconView.image = icon
        } else if let iconId = entry?.iconId {
            iconView.image = Icon(iconId).image
        }

        nameLabel.text = entry?.title
        userLabel.text = entry?.username
    }
}

extension ImageCell {

    func set(name: String, image: UIImage) {
        titleLabel?.text = name
        picture = image
    }
}
