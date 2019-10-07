// EntryCell.swift
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

public class EntryCell: UITableViewCell {

    @IBOutlet weak var iconView: UIImageView!

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var userLabel: UILabel!

    @IBOutlet weak var indicatorImageView: UIImageView!

    public var disclosureIndicatorVisible: Bool = true {
        didSet {
            indicatorImageView.isHidden = !disclosureIndicatorVisible
        }
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.textColor = Asset.grey.color
        indicatorImageView.image = Asset.disclosureIndicator.image
    }

    override public func prepareForReuse() {
        super.prepareForReuse()

        iconView.image = Icon.password.image
        nameLabel.text = nil
        disclosureIndicatorVisible = true
    }

}
