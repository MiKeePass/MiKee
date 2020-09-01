// EditEntryViewController.swift
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

public class EditEntryViewController: EntryViewController {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!

    public weak var delegate: ExtensionDelegate?

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Asset.background.color

        cancelButton.setTitle(L10n.cancel, for: .normal)
        cancelButton.setTitleColor(Asset.red.color, for: .normal)

        selectButton.setTitle(L10n.select, for: .normal)
        selectButton.setTitleColor(Asset.purple.color, for: .normal)
    }

    @IBAction func cancel(_ sender: Any) {
        delegate?.viewController(didCancel: self)
    }

    @IBAction func save(_ sender: Any) {
        guard let entry = entry else { return }
        delegate?.viewController(self, didSelect: entry)
    }

}
