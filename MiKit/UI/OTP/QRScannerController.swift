// QRScannerController.swift
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

/// Delegate callback for the QRScannerView.
public protocol QRScannerControllerDelegate: class {
    func scanner(_ scanner: QRScannerController, didFind code: String)
}

public class QRScannerController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var scannerView: QRScannerView!

    public weak var delegate: QRScannerControllerDelegate?

    public override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = L10n.qrCodeScanner
        titleLabel.textColor = Asset.purple.color

        closeButton.setImage(Asset.close.image, for: .normal)

        scannerView.delegate = self
    }

    @IBAction func dismiss(_ sender: Any?) {
        navigationController?.popViewController(animated: true)
    }
}

extension QRScannerController: QRScannerViewDelegate {

    public func scanner(_ scanner: QRScannerView, DidFailWith error: Error) {
        error.show()
    }

    public func scanner(_ scanner: QRScannerView, didFind code: String) {
        delegate?.scanner(self, didFind: code)
        dismiss(self)
    }

    public func scannerDidStop(_ scanner: QRScannerView) {

    }

}
