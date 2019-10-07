// DatabaseCell.swift
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
import MiKit

class DatabaseCell: UITableViewCell {

    @IBOutlet weak var databaseLabel: UILabel!
    @IBOutlet weak var keyField: FileField!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectKey = nil
        removeKey = nil

        databaseLabel.textColor = Asset.grey.color

        keyField.textColor = Asset.purple.color
        keyField.placeholder = L10n.selectKeyFile

        keyField.addTarget(self, action: #selector(selectKey(_:)), for: .add)
        keyField.addTarget(self, action: #selector(removeKey(_:)), for: .clear)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @objc func selectKey(_ sender: Any) {
        selectKey?(self)
    }

    @objc func removeKey(_ sender: Any) {
        removeKey?(self)
    }

    var selectKey: ((DatabaseCell) -> Void)?

    var removeKey: ((DatabaseCell) -> Void)?

}

extension DatabaseCell: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        selectKey?(self)
        return false
    }
}
