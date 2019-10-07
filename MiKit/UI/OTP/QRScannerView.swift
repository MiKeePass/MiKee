// QRScannerView.swift
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
import AVFoundation

/// Delegate callback for the QRScannerView.
public protocol QRScannerViewDelegate: class {
    func scanner(_ scanner: QRScannerView, DidFailWith error: Error)
    func scanner(_ scanner: QRScannerView, didFind code: String)
}

public class QRScannerView: UIView {

    // Overriding the layerClass to return `AVCaptureVideoPreviewLayer`.
    public override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    public override var layer: AVCaptureVideoPreviewLayer {
        return super.layer as! AVCaptureVideoPreviewLayer
    }

    public weak var delegate: QRScannerViewDelegate?

    /// capture settion which allows us to start and stop scanning.
    private let captureSession = AVCaptureSession()

    public var isRunning: Bool {
        return captureSession.isRunning
    }

    // Init methods..
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    public func startScanning() {
        captureSession.startRunning()
    }

    public func stopScanning() {
        captureSession.stopRunning()
    }

    /// Does the initial setup for captureSession
    private func initialize() {

        clipsToBounds = true

        do {

            guard let device = AVCaptureDevice.default(for: .video) else { return }

            let input = try AVCaptureDeviceInput(device: device)

            guard captureSession.canAddInput(input) else {
                throw MiError.QRScanner
            }

            captureSession.addInput(input)

            let output = AVCaptureMetadataOutput()

            guard captureSession.canAddOutput(output) else {
                throw MiError.QRScanner
            }

            captureSession.addOutput(output)

            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            output.metadataObjectTypes = [.qr, .ean8, .ean13, .pdf417]

            layer.session = captureSession
            layer.videoGravity = .resizeAspectFill

            captureSession.startRunning()

        } catch let error {
            delegate?.scanner(self, DidFailWith: error)
        }
    }

}

extension QRScannerView: AVCaptureMetadataOutputObjectsDelegate {

    public func metadataOutput(_ output: AVCaptureMetadataOutput,
                               didOutput metadataObjects: [AVMetadataObject],
                               from connection: AVCaptureConnection) {
        stopScanning()

        guard
            let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            let code = object.stringValue
        else { return }

        delegate?.scanner(self, didFind: code)
    }

}
