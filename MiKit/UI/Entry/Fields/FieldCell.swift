// FieldCell.swift
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
import FontAwesome_swift
import Navajo

class FieldCell: UITableViewCell {

    @IBOutlet weak var view: BorderView!

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var valueField: AttributeField?
    @IBOutlet weak var visibilityButton: UIButton?
    @IBOutlet weak var deleteButton: UIButton!

    var title: String? {
        get { return titleField.text }
        set { titleField.text = newValue }
    }

    var value: String? {
        get { return valueField?.text }
        set { valueField?.text = newValue }
    }

    var isDefault = false {
        didSet { valueField?.canEditProtection = !isDefault }
    }

    var isProtected = false {
        didSet {
            valueField?.isProtected = isProtected
            valueField?.checkStrength = isProtected
            valueField?.isSecureTextEntry = isProtected
            valueField?.font = isProtected ? UIFont(name: "Courier", size: 17) : UIFont.systemFont(ofSize: 17)
            visibilityButton?.isSelected = !isProtected
            visibilityButton?.isHidden = !isProtected
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        titleField.text = nil
        titleField.isEnabled = false
        titleField.textColor = Asset.grey.color
        titleField.tintColor = Asset.purple.color

        valueField?.text = nil
        valueField?.isEnabled = false
        valueField?.textColor = Asset.textColor.color
        valueField?.tintColor = Asset.purple.color

        deleteButton.isHidden = true
        deleteButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 17, style: .regular)
        deleteButton.setTitle(String.fontAwesomeIcon(name: .trashAlt), for: .normal)
        deleteButton.setTitleColor(Asset.grey.color, for: .normal)

        visibilityButton?.titleLabel?.font = UIFont.fontAwesome(ofSize: 17, style: .regular)
        visibilityButton?.setTitle(String.fontAwesomeIcon(name: .eye), for: .normal)
        visibilityButton?.setTitle(String.fontAwesomeIcon(name: .eyeSlash), for: .selected)
        visibilityButton?.setTitleColor(Asset.grey.color, for: .normal)
    }

    @IBAction func visibility(_ sender: UIButton) {
        guard let valueField = valueField else { return }

        sender.isSelected = !sender.isSelected
        valueField.isSecureTextEntry = !valueField.isSecureTextEntry
    }

    @IBAction func action(_ sender: AttributeField) {
        isProtected = sender.isProtected
    }

}

extension FieldCell {

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var isFirstResponder: Bool {
        return titleField.isFirstResponder || valueField?.isFirstResponder ?? false
    }

    @discardableResult override func becomeFirstResponder() -> Bool {
        titleField.isEnabled = !isDefault
        deleteButton.isHidden = false
        if let valueField = valueField {
            valueField.isEnabled = true
            valueField.isSecureTextEntry = false
            visibilityButton?.isHidden = true
            return valueField.becomeFirstResponder()
        }

        return isDefault ? false : titleField.becomeFirstResponder()
    }

    override var canResignFirstResponder: Bool {
        return titleField.canResignFirstResponder || valueField?.canResignFirstResponder ?? false
    }

    @discardableResult override func resignFirstResponder() -> Bool {
        titleField.isEnabled = false
        valueField?.isEnabled = false
        valueField?.isSecureTextEntry = isProtected
        visibilityButton?.isHidden = !isProtected
        deleteButton.isHidden = true

        if let valueField = valueField, valueField.isFirstResponder {
            return valueField.resignFirstResponder()
        }

        return titleField.resignFirstResponder()
    }

}

extension FieldCell: UITextFieldDelegate {

}
