// NoteCell.swift
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

class NoteCell: FieldCell {

    @IBOutlet weak var noteView: UITextView!

    override var value: String? {
        get { return noteView.text }
        set { noteView.text = newValue }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        noteView.text = nil
        noteView.tintColor = Asset.purple.color
        noteView.textContainer.lineFragmentPadding = 0
        noteView.textContainerInset = UIEdgeInsets.zero
    }

    @discardableResult override func becomeFirstResponder() -> Bool {
        noteView.isEditable = true
        return noteView?.becomeFirstResponder() ?? false
    }

}

extension NoteCell: UITextViewDelegate {

}
