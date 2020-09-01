// FileField.swift
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

@IBDesignable public class FileField: UITextField {

    let leftButton = UIButton()

    override public var text: String? {
        get { return super.text }
        set {
            if let text = newValue, !text.isEmpty {
                leftButton.isSelected = true
            } else {
                leftButton.isSelected = false
            }
            super.text = newValue
        }
    }

    @IBInspectable public var padding: CGFloat = 0 {
        didSet { setNeedsLayout() }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    func initialize() {

        leftView = leftButton
        leftViewMode = .always

        leftButton.addTarget(self, action: #selector(left), for: .touchUpInside)

        leftButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 12, style: .solid)

        leftButton.setTitleColor(Asset.purple.color, for: .selected)
        leftButton.setTitle(String.fontAwesomeIcon(name: .minusCircle), for: .selected)

        leftButton.setTitleColor(Asset.grey.color.withAlphaComponent(0.7), for: .normal)
        leftButton.setTitle(String.fontAwesomeIcon(name: .plusCircle), for: .normal)
    }

    @objc private func left() {
        if leftButton.isSelected {
            text = nil
            sendActions(for: .clear)
        } else {
            sendActions(for: .add)
        }
    }

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        var frame = bounds
        frame.origin.x = frame.height + padding
        frame.size.width -= frame.minX
        return frame
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

    override open func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var frame = bounds
        frame.size.width = frame.height
        return frame
    }

}

public extension UIControl.Event {

    static var add: UIControl.Event {
        return UIControl.Event(rawValue: 1 << 20)
    }

    static var clear: UIControl.Event {
        return UIControl.Event(rawValue: 1 << 21)
    }

}
