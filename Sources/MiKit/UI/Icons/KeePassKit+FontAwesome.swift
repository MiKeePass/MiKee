//
//  KeePassKit+FontAwesome.swift
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
import KeePassKit
import FontAwesome_swift

extension KPKIconType {

    public var fontAwesome: FontAwesome {
        switch self {
        case .packageNetwork: return .globe
        case .warning: return .exclamationTriangle
        case .server: return .server
        case .klipper: return .comments
        case .languages: return .puzzlePiece
        case .blockDevice: return .penSquare
        case .notepad: return .plug
        case .socket: return .newspaper
        case .identity: return .paperclip
        case .contact: return .user
        case .camera: return .camera
        case .remote: return .wifi
        case .keys: return .link
        case .battery: return .batteryThreeQuarters
        case .scanner: return .barcode
        case .browser: return .certificate
        case .cdRom: return .bullseye
        case .display: return .desktop
        case .email: return .envelope
        case .misc: return .cog
        case .organizer: return .clipboard
        case .ASCII: return .paperPlane
        case .icons: return .tv
        case .establishedConnection : return .bolt
        case .mailFolder: return .inbox
        case .fileSave: return .save
        case .nfsUnmount: return .hdd
        case .quickTime: return .dotCircle
        case .secureTerminal: return .expeditedssl
        case .terminal: return .terminal
        case .print : return .print
        case .fileSystemView: return .mapSigns
        case .run: return .flagCheckered
        case .configure: return .wrench
        case .browserWindow: return .laptop
        case .archive: return .archive
        case .percentage: return .creditCard
        case .sambaUnmount: return .windows
        case .history: return .clock
        case .findMail: return .search
        case .vector: return .flask
        case .memory: return .gamepad
        case .trash: return .trash
        case .notes: return .stickyNote
        case .cancel: return .ban
        case .help: return .questionCircle
        case .package: return .cube
        case .folder: return .folder
        case .folderOpen: return .folderOpen
        case .folderTar: return .database
        case .decrypted: return .unlockAlt
        case .encrypted: return .lock
        case .apply: return .check
        case .signature: return .pen
        case .thumbnail: return .image
        case .addressBook: return .book
        case .textView: return .listAlt
        case .secureAccount: return .userSecret
        case .development: return .laptopCode
        case .home: return .home
        case .services: return .star
        case .tux: return .linux
        case .feather: return .mapPin
        case .apple: return .apple
        case .wiki: return .wikipediaW
        case .money: return .dollarSign
        case .certificat: return .calendar
        case .phone: return .mobile
        default: return .key
        }
    }
}

extension NSInteger {

    public var fontAwesome: FontAwesome {
        switch self {
        case 1: return .globe
        case 2: return .exclamationTriangle
        case 3: return .server
        case 4: return .comments
        case 5: return .puzzlePiece
        case 6: return .pen
        case 7: return .plug
        case 8: return .newspaper
        case 9: return .paperclip
        case 10: return .user
        case 11: return .camera
        case 12: return .wifi
        case 13: return .link
        case 14: return .batteryThreeQuarters
        case 15: return .barcode
        case 16: return .certificate
        case 17: return .bullseye
        case 18: return .desktop
        case 19: return .envelope
        case 20: return .cog
        case 21: return .clipboard
        case 22: return .paperPlane
        case 23: return .tv
        case 24: return .bolt
        case 25: return .inbox
        case 26: return .save
        case 27: return .hdd
        case 28: return .dotCircle
        case 29: return .expeditedssl
        case 30: return .terminal
        case 31: return .print
        case 32: return .mapSigns
        case 33: return .flagCheckered
        case 34: return .wrench
        case 35: return .laptop
        case 36: return .archive
        case 37: return .creditCard
        case 38: return .windows
        case 39: return .clock
        case 40: return .search
        case 41: return .flask
        case 42: return .gamepad
        case 43: return .trash
        case 44: return .stickyNote
        case 45: return .ban
        case 46: return .questionCircle
        case 47: return .cube
        case 48: return .folder
        case 49: return .folderOpen
        case 50: return .database
        case 51: return .unlockAlt
        case 52: return .lock
        case 53: return .check
        case 54: return .pen
        case 55: return .image
        case 56: return .book
        case 57: return .listAlt
        case 58: return .userSecret
        case 59: return .laptopCode
        case 60: return .home
        case 61: return .star
        case 62: return .linux
        case 63: return .mapPin
        case 64: return .apple
        case 65: return .wikipediaW
        case 66: return .dollarSign
        case 67: return .calendar
        case 68: return .mobile
        default: return .key
        }
    }

}

extension NSInteger {

    public var fa: String {
        switch self {
        case 1: return "fa-globe"
        case 2: return "fa-exclamation-triangle"
        case 3: return "fa-server"
        case 4: return "fa-comments"
        case 5: return "fa-puzzle-piece"
        case 6: return "fa-pen"
        case 7: return "fa-plug"
        case 8: return "fa-newspaper"
        case 9: return "fa-paperclip"
        case 10: return "fa-user"
        case 11: return "fa-camera"
        case 12: return "fa-wifi"
        case 13: return "fa-link"
        case 14: return "fa-battery-three-quarters"
        case 15: return "fa-barcode"
        case 16: return "fa-certificate"
        case 17: return "fa-bullseye"
        case 18: return "fa-desktop"
        case 19: return "fa-envelope"
        case 20: return "fa-cog"
        case 21: return "fa-clipboard"
        case 22: return "fa-paper-plane"
        case 23: return "fa-television"
        case 24: return "fa-bolt"
        case 25: return "fa-inbox"
        case 26: return "fa-save"
        case 27: return "fa-hdd"
        case 28: return "fa-dot-circle"
        case 29: return "fa-expeditedssl"
        case 30: return "fa-terminal"
        case 31: return "fa-print"
        case 32: return "fa-map-signs"
        case 33: return "fa-flag-checkered"
        case 34: return "fa-wrench"
        case 35: return "fa-laptop"
        case 36: return "fa-archive"
        case 37: return "fa-credit-card"
        case 38: return "fa-windows"
        case 39: return "fa-clock"
        case 40: return "fa-search"
        case 41: return "fa-flask"
        case 42: return "fa-gamepad"
        case 43: return "fa-trash"
        case 44: return "fa-sticky-note"
        case 45: return "fa-ban"
        case 46: return "fa-question-circle"
        case 47: return "fa-cube"
        case 48: return "fa-folder"
        case 49: return "fa-folder-open"
        case 50: return "fa-database"
        case 51: return "fa-unlock-alt"
        case 52: return "fa-lock"
        case 53: return "fa-check"
        case 54: return "fa-pencil"
        case 55: return "fa-image"
        case 56: return "fa-book"
        case 57: return "fa-list-alt"
        case 58: return "fa-user-secret"
        case 59: return "fa-laptop-code"
        case 60: return "fa-home"
        case 61: return "fa-star"
        case 62: return "fa-linux"
        case 63: return "fa-map-pin"
        case 64: return "fa-apple"
        case 65: return "fa-wikipedia-w"
        case 66: return "fa-dollar-sign"
        case 67: return "fa-calendar"
        case 68: return "fa-mobile"
        default: return "fa-key"
        }
    }

}

extension UIImageView {

    public func set(fa: String?, color: UIColor = .black, backgroundColor: UIColor = .clear) {
        guard let fa = fa else {
            image = nil
            return
        }

        image = UIImage.fontAwesomeIcon(code: fa,
                                        style: .solid,
                                        textColor: color,
                                        size: imageSizeForAspectRatio(),
                                        backgroundColor: backgroundColor)
    }

    private func imageSizeForAspectRatio() -> CGSize {
        let fontAspectRatio: CGFloat = 1.28571429
        return CGSize(width: frame.width, height: frame.width / fontAspectRatio)
    }

}

extension UIImage {

    public static func fontAwesomeIcon(name: FontAwesome, style: FontAwesomeStyle, textColor: UIColor = .black) -> UIImage {
        let image = self.fontAwesomeIcon(name: name, style: style, textColor: textColor, size: CGSize(width: 24, height: 24))
        return image.withRenderingMode(.alwaysOriginal)
    }
}
