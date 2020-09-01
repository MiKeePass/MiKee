//
//  Database+Keychain.swift
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
import KeychainAccess

extension Database: NSSecureCoding {

    public static var supportsSecureCoding: Bool {
        return true
    }

}

extension Database {

    static let service = "MiKee"
    static let accessGroup = "C75GEDTP26.me.maxep.MiKee"

    public class func names() -> [String] {
        let keychain = Keychain(service: service, accessGroup: accessGroup)
        return keychain.allKeys()
    }

    public class  func all() -> [Database] {
        let keychain = Keychain(service: service, accessGroup: accessGroup)
        return keychain.allItems().compactMap {
            guard let data = $0["value"] as? Data else { return nil }
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? Database
        }
    }

    public class func with(name: String) -> Database? {
        let keychain = Keychain(service: service, accessGroup: accessGroup)

        do {
            return try keychain.get(name) {
                guard let data = $0?.data else { return nil }
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? Database
            }

        } catch {
            return nil
        }
    }

    public func remove() throws {
        let keychain = Keychain(service: Database.service, accessGroup: Database.accessGroup)
        try keychain.remove(name)
    }

    public class func clear() throws {
        let keychain = Keychain(service: service, accessGroup: accessGroup)
        try keychain.removeAll()
    }

    public func archive() throws {
        let keychain = Keychain(service: Database.service, accessGroup: Database.accessGroup)
        let data = NSKeyedArchiver.archivedData(withRootObject: self)
        try keychain.set(data, key: name)
    }
}
