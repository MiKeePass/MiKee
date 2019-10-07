// ImageCell.swift
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

class ImageCell: BinaryCell {

    @IBOutlet weak var pictureView: UIImageView!

    private var aspectRatio: NSLayoutConstraint?

    var picture: UIImage? {
        get { return pictureView.image }
        set {
            pictureView.image = newValue

            guard let image = newValue else { return }

            if let constraint = aspectRatio {
                pictureView.removeConstraint(constraint)
            }

            let ratio = image.size.width / image.size.height
            aspectRatio = pictureView.widthAnchor.constraint(equalTo: pictureView.heightAnchor, multiplier: ratio)
            aspectRatio?.isActive = true
        }
    }

}
