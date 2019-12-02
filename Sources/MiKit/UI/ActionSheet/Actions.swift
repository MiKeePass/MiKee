// Actions.swift
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
import Resources
import FontAwesome_swift

// MARK: - Action Button

final public class Button: ButtonAction {

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    func initialize() {
        titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        setTitleColor(Asset.textColor.color, for: .normal)
        backgroundColor = Asset.largeButtonBackground.color
    }
}

// MARK: - Segmented Action

final public class SegmentedControl: SegmentedAction {

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    override public init(items: [Any]?) {
        super.init(items: items)
        initialize()
    }

    func initialize() {
        let attributes = [NSAttributedString.Key.font : UIFont.fontAwesome(ofSize: 21, style: .solid),
                          NSAttributedString.Key.foregroundColor : UIColor.black]
        setTitleTextAttributes(attributes, for: .normal)
        tintColor = Asset.textColor.color
        backgroundColor = Asset.largeButtonBackground.color
    }
}

extension Array where Element == Action {

    public mutating func append(image: UIImage? = nil, title: String? = nil, handler: (() -> Void)? = nil) {
        let button = Button(image: image, title: title, handler: handler)
        append(button)
    }

    public mutating func append(icon: FontAwesome, title: String? = nil, handler: (() -> Void)? = nil) {
        let image = UIImage.fontAwesomeIcon(name: icon, style: .solid, textColor: .black, size: CGSize(width: 24, height: 24))
        let button = Button(image: image, title: title, handler: handler)
        append(button)
    }

    public mutating func append(items: [Any], handler: ((Int) -> Void)? = nil) {
        let button = SegmentedAction(items: items, handler: handler)
        append(button)
    }

    public mutating func append(icons: [FontAwesome], handler: ((Int) -> Void)? = nil) {
        var items = [String]()

        for icon in icons {
            let item = String.fontAwesomeIcon(name: icon)
            items.append(item)
        }

        let button = SegmentedControl(items: items, handler: handler)
        append(button)
    }
}
