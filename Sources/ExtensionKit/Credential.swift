// Credential.swift
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
import Resources
import MiKit
import MobileCoreServices

// App Extension Error

public enum ExtensionError: Int, CustomNSError {

    case cancelledByUser = 0
    case APINotAvailable = 1
    case failedToContactExtension = 2
    case failedToLoadItemProviderData = 3
    case collectFieldsScriptFailed = 4
    case fillFieldsScriptFailed = 5
    case unexpectedData = 6
    case failedToObtainURLStringFromWebView = 7

    /// The domain of the error.
    public static var errorDomain: String {
        return "MiKeeExtension"
    }

    /// The error code within the given domain.
    public var errorCode: Int {
        return rawValue
    }

    /// The user-info dictionary.
    public var errorUserInfo: [String: Any] {
        var userInfo = [String: Any]()
        userInfo[NSLocalizedDescriptionKey] = L10n.error + " \(errorCode)"
        return userInfo
    }

}

public struct Credential {

    public enum Action {
        case safari
        case chrome
        case find
        case save
        case change
    }

    public struct PasswordOptions {

        public var minLength = 4
        public var maxLength = 50
        public var digits = true
        public var symbols = true
        public var forbiddenCharacters = ""

        public init() { }

        public func generate() -> String {

            let upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            let lower = "abcdefghijklmnopqrstuvwxyz"
            let digits = "0123456789"
            let symbols = "!@#$%^&*()_-+=|[]{}'\";.,>?/~`"

            let length = UInt32(minLength) + arc4random_uniform(UInt32(maxLength - minLength))
            var characters = upper + lower

            var password = ""

            if self.digits {
                password.append(digits.randomCharacter)
                characters += digits
            }

            if self.symbols {
                password.append(symbols.randomCharacter)
                characters += symbols
            }

            while password.count < length {
                password.append(characters.randomCharacter)
            }

            return password.shuffle()
        }

    }

    public let url: URL
    public let action: Action

    public var title: String?
    public var username: String?
    public var password: String?
    public var oldPassword: String?
    public var totp: String?
    public var notes: String?
    public var fields: [String: String]?

    public var passwordOptions = PasswordOptions()

    public init(action: Action, url: URL) {
        self.url = url
        self.action = action
    }

}

extension String {

    var randomCharacter: Character {
        let rand = arc4random_uniform(UInt32(count))
        let index = self.index(startIndex, offsetBy: Int(rand))
        return self[index]
    }

    func shuffle() -> String {
        var characters = Array(self)

        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            characters.swapAt(i, j)
        }

        return String(characters)
    }
}
