// FieldViewController.swift
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

protocol FieldViewControllerDelegate: class {
    func fieldViewController(_ fieldViewController: FieldViewController, willUpdate attribute: KPKAttribute)
    func fieldViewController(_ fieldViewController: FieldViewController, didUpdate attribute: KPKAttribute)
    func fieldViewController(_ fieldViewController: FieldViewController, delete attribute: KPKAttribute)
    func fieldViewController(didDismiss fieldViewController: FieldViewController)
}

class FieldViewController: UIViewController {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contentView: UIView!

    weak var titleField: UITextField?

    var attribute: KPKAttribute!

    weak var delegate: FieldViewControllerDelegate?

    private(set) var cell: FieldCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.backgroundColor = Asset.background.color

        switch attribute.key {

        case kKPKNotesKey:
            cell = NoteCell.instantiate(owner: self)

        default:
            cell = FieldCell.instantiate(owner: self)
        }

        guard let cell = cell else { return }

        cell.set(attribute: attribute)

        contentView.addSubview(cell.view)
        closeButton.setImage(Asset.close.image, for: .normal)

        saveButton.setTitle(L10n.save, for: .normal)
        saveButton.setTitleColor(Asset.purple.color, for: .normal)

        separatorView.backgroundColor = Asset.lightGrey.color

        // Place the cell within its container
        cell.view.translatesAutoresizingMaskIntoConstraints = false
        cell.view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        contentView.bottomAnchor.constraint(equalTo: cell.view.bottomAnchor, constant: 8).isActive = true
        cell.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        contentView.trailingAnchor.constraint(equalTo: cell.view.trailingAnchor, constant: 16).isActive = true

        cell.deleteButton.addTarget(self, action: #selector(remove(_:)), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cell.becomeFirstResponder()
    }

    @IBAction func save(_ sender: Any) {

        guard let value = cell.value, !value.isEmpty else {
            return MiError.noValue.show()
        }

        delegate?.fieldViewController(self, willUpdate: attribute)

        attribute.value = cell.value

        if !attribute.isDefault() {
            attribute.key = cell.title
            attribute.protect = cell.isProtected
        }

        delegate?.fieldViewController(self, didUpdate: attribute)

        close(sender)
    }

    @IBAction func close(_ sender: Any) {
        cell.resignFirstResponder()

        dismiss(animated: true) {
            self.delegate?.fieldViewController(didDismiss: self)
        }
    }

    @IBAction func remove(_ sender: Any) {
        delegate?.fieldViewController(self, delete: attribute)
        close(sender)
    }

}
