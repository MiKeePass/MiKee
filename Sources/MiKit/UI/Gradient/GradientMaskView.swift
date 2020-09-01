// GradientMaskView.swift
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

import UIKit

@IBDesignable
class GradientMaskView: UIView {

    @IBInspectable
    public var topInset: CGFloat = 8

    @IBInspectable
    public var bottomInset: CGFloat = 8

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }

    private var gradient = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    private func initialize() {
        backgroundColor = .clear

        gradient.colors = [UIColor.clear.cgColor,
                           UIColor.white.cgColor,
                           UIColor.white.cgColor,
                           UIColor.clear.cgColor]

        layer.mask = gradient
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let top = Float(topInset / bounds.height)
        let bottom = Float(1 - (bottomInset / bounds.height))

        gradient.locations = [0,
                              NSNumber(value: top),
                              NSNumber(value: bottom),
                              1]

        gradient.frame = bounds
    }
}
