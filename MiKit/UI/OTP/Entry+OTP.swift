//
//  Entry+OTP.swift
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

import KeePassKit
import OneTimePassword
import Base32

let TOTPSeedKey = "TOTP Seed"
let TOTPSettingsKey = "TOTP Settings"

extension KPKEntry {

    public var token: Token? {

        for attribute in customAttributes {

            if
                let value = attribute.value,
                let url = URL(string: value),
                let token = Token(url: url)
            {
                return token
            }

            if
                attribute.key == TOTPSeedKey,
                let secret = attribute.value,
                let settings = self.attribute(withKey: TOTPSettingsKey)?.value,
                let token = Token(secret: secret, settings: settings)
            {
                return token
            }

        }

        return nil
    }

}

extension Token {

    init?(secret: String, settings: String) {
        let settings = settings.split(separator: ";")

        guard
            settings.count > 1,
            let secret = MF_Base32Codec.data(fromBase32String: secret),
            let time = TimeInterval(settings[0]),
            let digits = Int(settings[1]),
            let generator = Generator(factor: .timer(period: time), secret: secret, algorithm: .sha1, digits: digits)
        else { return nil }

        self.init(generator: generator)
    }
}
