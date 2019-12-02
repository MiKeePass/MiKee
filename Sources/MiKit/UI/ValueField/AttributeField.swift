// AttributeField.swift
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
import FontAwesome_swift
import Navajo

class AttributeField: UITextField {

    var isProtected = true {
        didSet { reload() }
    }

    var canEditProtection = true {
        didSet { reload() }
    }

    var canGenerateValue = true {
        didSet { reload() }
    }

    var checkStrength = true {
        didSet { reload() }
    }

    override var text: String? {
        get { return super.text }
        set {
            super.text = newValue
            updateStrenght(newValue)
        }
    }

    @IBOutlet var accessoryView: UIView!
    @IBOutlet var topSeparatorView: UIView!
    @IBOutlet var accessoryStackView: UIStackView!
    @IBOutlet var passwordCheckView: PasswordStrengthView!
    @IBOutlet var lockButton: UIButton!
    @IBOutlet var passwordGeneratorButton: UIButton!

    @IBOutlet var generatorView: PasswordGeneratorView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    func initialize() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ValueKeyboard", bundle: bundle)
        nib.instantiate(withOwner: self, options: nil)

        accessoryView?.tintColor = Asset.textColor.color
        accessoryView?.backgroundColor = Asset.background.color
        generatorView?.backgroundColor = Asset.background.color

        topSeparatorView.backgroundColor = Asset.lightGrey.color

        lockButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 17, style: .solid)
        lockButton.setTitleColor(Asset.purple.color, for: .normal)
        lockButton.setTitle(String.fontAwesomeIcon(name: .unlock), for: .normal)
        lockButton.setTitle(String.fontAwesomeIcon(name: .lock), for: .selected)

        passwordGeneratorButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 17, style: .solid)
        passwordGeneratorButton.setTitleColor(Asset.purple.color, for: .normal)
        passwordGeneratorButton.setTitle(String.fontAwesomeIcon(name: .bolt), for: .normal)
        passwordGeneratorButton.setTitle(String.fontAwesomeIcon(name: .keyboard), for: .selected)

        passwordCheckView.tintColor = Asset.purple.color

        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        reload()
    }

    private func reload() {

        passwordCheckView.isHidden = !checkStrength

        if canEditProtection {
            lockButton.isSelected = isProtected
            accessoryStackView.addArrangedSubview(lockButton)
        } else {
            lockButton.removeFromSuperview()
        }

        if canGenerateValue {
            passwordGeneratorButton.isSelected = inputView == generatorView
            accessoryStackView.addArrangedSubview(passwordGeneratorButton)
        } else {
            passwordGeneratorButton.removeFromSuperview()
        }

        if checkStrength || canEditProtection || canGenerateValue {
            inputAccessoryView = accessoryView
        } else {
            inputAccessoryView = nil
        }

        reloadInputViews()
    }

    @IBAction func lock(_ sender: Any) {
        isProtected = !isProtected
        sendActions(for: .primaryActionTriggered)
    }

    @IBAction func keyboard(_ sender: Any) {
        inputView = inputView == generatorView ? nil : generatorView
        reload()
    }

    @IBAction func passwordDidChange(_ sender: PasswordGeneratorView) {
        text = sender.password
    }

    @objc func textDidChange() {
        updateStrenght(text)
    }

    func updateStrenght(_ text: String?) {
        guard checkStrength else { return }

        let color: UIColor?

        switch NJOPasswordStrengthEvaluator.strength(ofPassword: text) {
        case .veryWeakPasswordStrength:
            passwordCheckView.visibleSegmentCount = 1
            color = Asset.red.color

        case .weakPasswordStrength:
            passwordCheckView.visibleSegmentCount = 2
            color = .orange

        case .reasonablePasswordStrength:
            passwordCheckView.visibleSegmentCount = 3
            color = Asset.green.color

        case .strongPasswordStrength:
            passwordCheckView.visibleSegmentCount = 4
            color = .cyan

        case .veryStrongPasswordStrength:
            passwordCheckView.visibleSegmentCount = 5
            color = Asset.purple.color
        default: color = nil
        }

        generatorView?.lengthSlider.tintColor = color
        passwordCheckView.visibleSegmentColor = color
    }

}
