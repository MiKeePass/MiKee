// PasswordGeneratorView.swift
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

enum CharSet: String {
    case upper = "ABCDEFGHJKLMNPQRSTUVWXYZ"
    case lower = "abcdefghijkmnpqrstuvwxyz"
    case digits = "123456789"
    case special = "!@#$%^&*_+-=./?;:`\"~'\\"
    case brackets = "(){}[]<>"
    case high = "¡¢£¤¥¦§©ª«¬®¯°±²³´µ¶¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþ"
    case ambiguous = "O0oIl"
}

extension Array where Element == CharSet {

    func generate(length: UInt) -> String {
        let chars = join()
        guard !chars.isEmpty else { return "" }

        var str = ""
        for _ in 0..<length {
            let rand = arc4random_uniform(UInt32(chars.count))
            let index = chars.index(chars.startIndex, offsetBy: Int(rand))
            let char = chars[index]
            str.append(char)
        }

        return str
    }

    private func join() -> String {
        var str = ""
        for charset in self {
            str += charset.rawValue
        }
        return str
    }

}

class PasswordGeneratorView: UIControl {

    @IBOutlet weak var upperButton: UIButton!
    @IBOutlet weak var lowerButton: UIButton!
    @IBOutlet weak var digitsButton: UIButton!
    @IBOutlet weak var specialButton: UIButton!
    @IBOutlet weak var bracketsButton: UIButton!
    @IBOutlet weak var highButton: UIButton!
    @IBOutlet weak var lengthSlider: UISlider!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var lengthLabel: UILabel!

    private(set) var password: String?
    var charsets: [CharSet] = [.upper, .lower, .digits]

    override func awakeFromNib() {
        super.awakeFromNib()

        upperButton.isSelected = charsets.contains(.upper)
        upperButton.setTitleColor(Asset.grey.color, for: .normal)
        upperButton.setTitleColor(Asset.purple.color, for: .selected)

        lowerButton.isSelected = charsets.contains(.lower)
        lowerButton.setTitleColor(Asset.grey.color, for: .normal)
        lowerButton.setTitleColor(Asset.purple.color, for: .selected)

        digitsButton.isSelected = charsets.contains(.digits)
        digitsButton.setTitleColor(Asset.grey.color, for: .normal)
        digitsButton.setTitleColor(Asset.purple.color, for: .selected)

        specialButton.isSelected = charsets.contains(.special)
        specialButton.setTitleColor(Asset.grey.color, for: .normal)
        specialButton.setTitleColor(Asset.purple.color, for: .selected)

        bracketsButton.isSelected = charsets.contains(.brackets)
        bracketsButton.setTitleColor(Asset.grey.color, for: .normal)
        bracketsButton.setTitleColor(Asset.purple.color, for: .selected)

        highButton.isSelected = charsets.contains(.high)
        highButton.setTitleColor(Asset.grey.color, for: .normal)
        highButton.setTitleColor(Asset.purple.color, for: .selected)

        refreshButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 22, style: .solid)
        refreshButton.setTitle(String.fontAwesomeIcon(name: .syncAlt), for: .normal)
        refreshButton.setTitleColor(Asset.grey.color, for: .normal)

        lengthSlider.value = 16
        lengthSlider.maximumTrackTintColor = Asset.lightGrey.color
        lengthSlider.tintColor = .black

        lengthLabel.text = L10n.length("16")
        lengthLabel.textColor = Asset.grey.color

    }

    @IBAction func upper(_ sender: Any) {
        upperButton.isSelected = !upperButton.isSelected
        refresh(sender)
    }

    @IBAction func lower(_ sender: Any) {
        lowerButton.isSelected = !lowerButton.isSelected
        refresh(sender)
    }

    @IBAction func digits(_ sender: Any) {
        digitsButton.isSelected = !digitsButton.isSelected
        refresh(sender)
    }

    @IBAction func special(_ sender: Any) {
        specialButton.isSelected = !specialButton.isSelected
        refresh(sender)
    }

    @IBAction func brackets(_ sender: Any) {
        bracketsButton.isSelected = !bracketsButton.isSelected
        refresh(sender)
    }

    @IBAction func high(_ sender: Any) {
        highButton.isSelected = !highButton.isSelected
        refresh(sender)
    }

    @IBAction func slide(_ sender: Any) {
        lengthLabel.text = L10n.length("\(Int(lengthSlider.value))")
        refresh(sender)
    }

    @IBAction func refresh(_ sender: Any) {

        charsets.removeAll()
        if upperButton.isSelected { charsets.append(.upper) }
        if lowerButton.isSelected { charsets.append(.lower) }
        if digitsButton.isSelected { charsets.append(.digits) }
        if specialButton.isSelected { charsets.append(.special) }
        if bracketsButton.isSelected { charsets.append(.brackets) }
        if highButton.isSelected { charsets.append(.high) }

        password = charsets.generate(length: UInt(lengthSlider.value))
        sendActions(for: .valueChanged)
    }
}
