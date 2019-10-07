// OTPAlertViewController.swift
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
import MiKit
import Resources
import OneTimePassword

class OTPAlertViewController: AlertViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var otpLabel: OTPLabel!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    @IBOutlet weak var separatorView: UIView!

    private var token: Token?

    private var completion: (() -> Void)?

    public convenience init(token: Token, _ completion: @escaping () -> Void) {
        self.init()
        self.token = token
        self.completion = completion
    }

    override func loadView() {
        super.loadView()

        let nib = UINib(nibName: "OTP",
                        bundle: Bundle(for: OTPAlertViewController.self))
        nib.instantiate(withOwner: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Asset.background.color

        titleLabel.text = L10n.thisAccountRequiresAnOTPYouCanUseTheFollowingCode
        titleLabel.textColor = Asset.grey.color

        otpLabel.text = nil
        otpLabel.alpha = 0
        otpLabel.textColor = Asset.purple.color
        otpLabel.token = token

        copyButton.setTitle(L10n.copy, for: .normal)
        copyButton.setTitleColor(Asset.purple.color, for: .normal)

        cancelButton.setTitle(L10n.okGotIt, for: .normal)
        cancelButton.setTitleColor(Asset.grey.color, for: .normal)

        separatorView.backgroundColor = Asset.lightGrey.color
    }

    @IBAction func clipboard(_ sender: Any) {
        UIPasteboard.general.string = token?.currentPassword
        dismiss(animated: true, completion: completion)
    }

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: completion)
    }

}
