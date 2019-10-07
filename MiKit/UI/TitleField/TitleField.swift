// TitleField.swift
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

@IBDesignable open class TitleField: UITextField {

    let iconView = UIImageView()

    @IBOutlet var accessoryView: UIToolbar?
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var keyboardButton: FontAwesomeBarButtonItem!
    @IBOutlet var iconKeyboardView: UIView?

    @IBOutlet weak var collectionView: UICollectionView!

    @IBInspectable public var iconId: Int = 0 {
        didSet {
            iconImage = Icon(iconId).image?.withSize(width: 22, height: 22)?.withRenderingMode(.alwaysOriginal)

            collectionView.deselectItem(at: IndexPath(row: oldValue, section: 0), animated: true)
            collectionView.selectItem(at: IndexPath(row: iconId, section: 0), animated: true, scrollPosition: .centeredHorizontally)
            setNeedsLayout()
        }
    }

    public var customIcons: [KPKIcon]? {
        didSet { collectionView.reloadData() }
    }

    public var selectedIcon: KPKIcon? {
        didSet {
            guard let icons = customIcons else { return }

            if let icon = oldValue, let row = icons.firstIndex(of: icon) {
                collectionView.deselectItem(at: IndexPath(row: row, section: 1), animated: true)
            }

            if let icon = selectedIcon, let row = icons.firstIndex(of: icon) {
                collectionView.selectItem(at: IndexPath(row: row, section: 1), animated: true, scrollPosition: .centeredHorizontally)
            }

            setNeedsLayout()
        }
    }

    private var iconImage: UIImage?

    @IBInspectable public var padding: CGFloat = 8 {
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
        iconView.contentMode = .scaleAspectFit

        leftView = iconView
        leftViewMode = .always

        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "TitleKeyboard", bundle: bundle)
        nib.instantiate(withOwner: self, options: nil)

        inputAccessoryView = accessoryView
        closeButton.tintColor = Asset.lightGrey.color
        closeButton.image = Asset.close.image

        saveButton.tintColor = Asset.purple.color
        saveButton.title = L10n.save

        collectionView.register(IconCell.self, forCellWithReuseIdentifier: "icon")

        accessoryView?.tintColor = Asset.textColor.color
        accessoryView?.barTintColor = Asset.background.color
        iconKeyboardView?.backgroundColor = Asset.background.color
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        if let selectedIcon = selectedIcon {
            iconView.image = selectedIcon.image
        } else {
            iconView.image = Icon(iconId).image
        }

        if inputView == nil {
            keyboardButton.image = iconImage
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

    override open var intrinsicContentSize: CGSize {
        guard let text = text else {
            return CGSize(width: 24, height: 24)
        }

        var size = text.size(withAttributes: [.font : font ?? UIFont.systemFont(ofSize: 12)])
        size = CGSize(width: ceil(size.width), height: ceil(size.height))

        size.width += size.height
        size.width += padding

        return size
    }

    @IBAction func switchKeyboard(_ sender: FontAwesomeBarButtonItem) {

        inputView = inputView == iconKeyboardView ? nil : iconKeyboardView
        reloadInputViews()

        if inputView == iconKeyboardView {
            sender.image = UIImage.fontAwesomeIcon(name: .keyboard,
                                                   style: .regular,
                                                   textColor: Asset.textColor.color,
                                                   size: CGSize(width: 24, height: 24))
        } else {
            sender.image = iconImage
        }
    }

    @IBAction func cancel(_ sender: Any) {
        sendActions(for: .cancel)
    }

    @IBAction func save(_ sender: Any) {
        sendActions(for: .save)
    }
}

extension TitleField: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section > 0 {
            return customIcons?.count ?? 0
        }
        return 69
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "icon", for: indexPath) as! IconCell

        if indexPath.section > 0 {
            cell.iconView.image = customIcons?[indexPath.row].image
        } else {
            cell.iconId = indexPath.row
        }

        return cell
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 44, height: 44)
    }

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        iconId = indexPath.row
    }

}

class IconCell: UICollectionViewCell {

    let iconView = UIImageView()

    @IBInspectable var iconId: Int = 0 {
        didSet { setNeedsLayout() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    func initialize() {
        iconView.contentMode = .scaleAspectFit
        contentView.addSubview(iconView)

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = Asset.purple.color.withAlphaComponent(0.2)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        iconView.frame.size = CGSize(width: 24, height: 24)
        iconView.center = contentView.center
        iconView.image = Icon(iconId).image
    }

}

extension UIControl.Event {

    public static var cancel: UIControl.Event {
        return UIControl.Event(rawValue: 1 << 20)
    }

    public static var save: UIControl.Event {
        return UIControl.Event(rawValue: 1 << 21)
    }

}
