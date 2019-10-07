// OTPLabel.swift
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
import OneTimePassword

public class OTPLabel: UILabel {

    public var token: Token? {
        didSet {
            alpha = 0
            update()
        }
    }

    private func update() {
        guard let token = token, case let .timer(period) = token.generator.factor else { return }

        let time = Date().timeIntervalSince1970
        let round = UInt64(time / period)

        let percent = (time / period) - Double(round)
        let alpha = 1.1 - CGFloat(percent)

        if alpha > self.alpha {
            let code = NSMutableAttributedString(string: token.currentPassword ?? "")
            code.addAttribute(NSAttributedString.Key.kern, value: 5, range: NSRange(location: 0, length: code.length))
            attributedText = code
        }

        self.alpha = 1.1 - CGFloat(percent)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: update)
    }

}
