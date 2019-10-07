// Icon.swift
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

public enum Icon: String {

    case password = "C00_Password"
    case packageNetwork = "C01_Package_Network"
    case warning = "C02_MessageBox_Warning"
    case server = "C03_Server"
    case klipper = "C04_Klipper"
    case languages = "C05_Edu_Languages"
    case blockDevice = "C06_KCMDF"
    case notepad = "C07_Kate"
    case socket = "C08_Socket"
    case identity = "C09_Identity"
    case contact = "C10_Kontact"
    case camera = "C11_Camera"
    case remote = "C12_IRKickFlash"
    case keys = "C13_KGPG_Key3"
    case battery = "C14_Laptop_Power"
    case scanner = "C15_Scanner"
    case browser = "C16_Mozilla_Firebird"
    case cdRom = "C17_CDROM_Unmount"
    case display = "C18_Display"
    case email = "C19_Mail_Generic"
    case misc = "C20_Misc"
    case organizer = "C21_KOrganizer"
    case ASCII = "C22_ASCII"
    case icons = "C23_Icons"
    case establishedConnection = "C24_Connect_Established"
    case mailFolder = "C25_Folder_Mail"
    case fileSave = "C26_FileSave"
    case nfsUnmount = "C27_NFS_Unmount"
    case quickTime = "C28_Message"
    case secureTerminal = "C29_KGPG_Term"
    case terminal = "C30_Konsole"
    case print = "C31_FilePrint"
    case fileSystemView = "C32_FSView"
    case run = "C33_Run"
    case configure = "C34_Configure"
    case browserWindow = "C35_KRFB"
    case archive = "C36_Ark"
    case percentage = "C37_KPercentage"
    case sambaUnmount = "C38_Samba_Unmount"
    case history = "C39_History"
    case findMail = "C40_Mail_Find"
    case vector = "C41_VectorGfx"
    case memory = "C42_KCMMemory"
    case trash = "C43_Trashcan_Full"
    case notes = "C44_KNotes"
    case cancel = "C45_Cancel"
    case help = "C46_Help"
    case package = "C47_KPackage"
    case folder = "C48_Folder"
    case folderOpen = "C49_Folder_Blue_Open"
    case folderTar = "C50_Folder_Tar"
    case decrypted = "C51_Decrypted"
    case encrypted = "C52_Encrypted"
    case apply = "C53_Apply"
    case signature = "C54_Signature"
    case thumbnail = "C55_Thumbnail"
    case addressBook = "C56_KAddressBook"
    case textView = "C57_View_Text"
    case secureAccount = "C58_KGPG"
    case development = "C59_Package_Development"
    case home = "C60_KFM_Home"
    case services = "C61_Services"
    case tux = "C62_Tux"
    case feather = "C63_Feather"
    case apple = "C64_Apple"
    case wiki = "C65_W"
    case money = "C66_Money"
    case certificat = "C67_Certificate"
    case phone = "C68_Smartphone"

    public var image: UIImage? {
        let bundle = Bundle(for: Foo.self)
        return UIImage(named: rawValue, in: bundle, compatibleWith: nil)
    }

    private class Foo {}
}

extension Icon: ExpressibleByIntegerLiteral {

    public init(_ value: Int) { // swiftlint:disable:this cyclomatic_complexity function_body_length
        switch value {
        case 1: self = .packageNetwork
        case 2: self = .warning
        case 3: self = .server
        case 4: self = .klipper
        case 5: self = .languages
        case 6: self = .blockDevice
        case 7: self = .notepad
        case 8: self = .socket
        case 9: self = .identity
        case 10: self = .contact
        case 11: self = .camera
        case 12: self = .remote
        case 13: self = .keys
        case 14: self = .battery
        case 15: self = .scanner
        case 16: self = .browser
        case 17: self = .cdRom
        case 18: self = .display
        case 19: self = .email
        case 20: self = .misc
        case 21: self = .organizer
        case 22: self = .ASCII
        case 23: self = .icons
        case 24: self = .establishedConnection
        case 25: self = .mailFolder
        case 26: self = .fileSave
        case 27: self = .nfsUnmount
        case 28: self = .quickTime
        case 29: self = .secureTerminal
        case 30: self = .terminal
        case 31: self = .print
        case 32: self = .fileSystemView
        case 33: self = .run
        case 34: self = .configure
        case 35: self = .browser
        case 36: self = .archive
        case 37: self = .percentage
        case 38: self = .sambaUnmount
        case 39: self = .history
        case 40: self = .findMail
        case 41: self = .vector
        case 42: self = .memory
        case 43: self = .trash
        case 44: self = .notes
        case 45: self = .cancel
        case 46: self = .help
        case 47: self = .package
        case 48: self = .folder
        case 49: self = .folderOpen
        case 50: self = .folderTar
        case 51: self = .decrypted
        case 52: self = .encrypted
        case 53: self = .apply
        case 54: self = .signature
        case 55: self = .thumbnail
        case 56: self = .addressBook
        case 57: self = .textView
        case 58: self = .secureAccount
        case 59: self = .development
        case 60: self = .home
        case 61: self = .services
        case 62: self = .tux
        case 63: self = .feather
        case 64: self = .apple
        case 65: self = .wiki
        case 66: self = .money
        case 67: self = .certificat
        case 68: self = .phone
        default: self = .password
        }
    }

    public init(integerLiteral value: Int) {
        self.init(value)
    }

}
