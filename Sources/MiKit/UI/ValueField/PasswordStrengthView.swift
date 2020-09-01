// PasswordStrengthView.swift
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

@IBDesignable
public class PasswordStrengthView: UIView {

    private var layers = [CALayer]()

    @IBInspectable
    private var _segmentCount: CGFloat {
        get { return CGFloat(segmentCount) }
        set { segmentCount = Int(newValue) }
    }

    public var segmentCount: Int = 5 {
        willSet {
            for layer in layers {
                layer.removeFromSuperlayer()
            }
            layers.removeAll()
        }
        didSet {
            for _ in 0..<segmentCount {
                let layer = CALayer()
                self.layer.addSublayer(layer)
                layers.append(layer)
            }
            layout()
        }
    }

    @IBInspectable
    private var _visibleSegmentCount: CGFloat {
        get { return CGFloat(visibleSegmentCount) }
        set { segmentCount = Int(newValue) }
    }

    public var visibleSegmentCount: Int = 3 {
        didSet { layout() }
    }

    @IBInspectable
    public var visibleSegmentColor: UIColor! {
        didSet { layout() }
    }

    @IBInspectable
    public var padding: CGFloat = 2 {
        didSet { layout() }
    }

    @IBInspectable
    private var segmentCornerRadius: CGFloat = 1 {
        didSet { layout() }
    }

    /// :nodoc:
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initalize()
    }

    /// :nodoc:
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initalize()
    }

    private func initalize() {

        for _ in 0..<segmentCount {
            let layer = CALayer()
            self.layer.addSublayer(layer)
            layers.append(layer)
        }

        visibleSegmentColor = tintColor
    }

    // MARK: - Layout

    /// :nodoc:
    public override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }

    private func layout() {

        let count = CGFloat(segmentCount)
        let width = (bounds.width / count) - padding

        CATransaction.begin()

        var x: CGFloat = 0

        for index in 0..<layers.count {
            let layer = layers[index]
            layer.frame = CGRect(x: x, y: 0, width: width, height: bounds.height)
            x += width + padding

            layer.cornerRadius = segmentCornerRadius
            layer.backgroundColor = visibleSegmentColor.cgColor
            layer.isHidden = index >= visibleSegmentCount
        }

        CATransaction.commit()
    }

    /// :nodoc:
    public override func prepareForInterfaceBuilder() {
        segmentCount = 5
        visibleSegmentColor = tintColor
        layout()
    }

    /// :nodoc:
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 4)
    }

}
