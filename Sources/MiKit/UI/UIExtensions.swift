//
//  UIKit+MiKee.swift
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

// MARK: - UIImage Extension

public class MiKee {

    public static func appearance() {
        UITableView.appearance().backgroundColor = Asset.background.color
        UITableViewCell.appearance().backgroundColor = Asset.background.color
        BorderView.appearance().backgroundColor = Asset.background.color
        BorderControl.appearance().backgroundColor = Asset.background.color
        UITextView.appearance().backgroundColor = Asset.background.color

        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = Asset.largeButtonBackground.color

        UILabel.appearance().tintColor = Asset.textColor.color
        UITextField.appearance().tintColor = Asset.textColor.color
        UITextView.appearance().tintColor = Asset.textColor.color
    }
}

public extension UIImage {

    static func from(color name: String, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        guard let color = UIColor(named: name) else { return nil }
        return from(color, size: size)
    }

    static func from(_ color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let rect = CGRect(origin: CGPoint.zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    func withSize(width: CGFloat, height: CGFloat) -> UIImage? {
        let size = self.size.applying(CGAffineTransform(scaleX: 0.5, y: 0.5))
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: CGPoint.zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

// MARK: - UITableViewCell Extension

public extension UITableViewCell {

    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }

    class func instantiate(owner: Any?, options: [UINib.OptionsKey : Any]? = nil) -> Self {
        return instantiate(self, owner: owner, options: options)
    }

    private class func instantiate<T>(_ type: T.Type, owner: Any?, options: [UINib.OptionsKey : Any]? = nil) -> T {
        return nib.instantiate(withOwner: owner, options: options).first as! T
    }

}

// MARK: - UIColor Extension

public extension UIColor {

    func image(size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIImage.from(self, size: size)
    }

}

// MARK: - Border UIView

extension CALayer {

    func drawBorder(color: UIColor) {
        borderColor = color.cgColor
        borderWidth = 0.5
        cornerRadius = 9

        shadowOpacity = 0.02
        shadowOffset = CGSize(width: 0, height: 2)
    }
}

@IBDesignable
open class BorderView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    private func initialize() {
        layer.drawBorder(color: Asset.lightGrey.color)
    }

}

@IBDesignable
open class BorderControl: UIControl {

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    private func initialize() {
        layer.drawBorder(color: Asset.lightGrey.color)
    }

}

@IBDesignable
open class BorderButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    private func initialize() {
        update()
        addTarget(self, action: #selector(update), for: .allEvents)
    }

    open override var isEnabled: Bool {
        get { return super.isEnabled }
        set {
            super.isEnabled = newValue
            guard !isEnabled else { return }
            update()
        }
    }

    open override var isHighlighted: Bool {
        get { return super.isHighlighted }
        set {
            super.isHighlighted = newValue
            update()
        }
    }

    open override var isSelected: Bool {
        get { return super.isSelected }
        set {
            super.isSelected = newValue
            update()
        }
    }

    open override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        super.setTitleColor(color, for: state)
        guard self.state == state else { return }
        layer.drawBorder(color: color ?? Asset.lightGrey.color)
    }

    @objc
    private func update() {
        let color = titleColor(for: state)
        layer.drawBorder(color: color ?? Asset.lightGrey.color)
    }

}
