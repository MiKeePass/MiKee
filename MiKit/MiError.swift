// MiError.swift
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

public enum MiError: Error {
    case unknown
    case message(String)
    case createFile
    case openFile
    case copyFile
    case locked
    case wrongPasswordOrKey
    case passwordMismatch
    case noPasswordValue
    case noValue
    case QRScanner
    case alreadyExist(String)
}

public func safely(do: () throws -> Void) {
    do {
        try `do`()
    } catch {
        error.show()
    }
}

@discardableResult
public func safely<T>(do: () throws -> T, catch: () -> T) -> T {
    do {
        return try `do`()
    } catch {
        error.show()
        return `catch`()
    }
}

public extension Error {

    var banner: Banner {

        let banner = ErrorBanner()

        do {
            throw self

        } catch MiError.noValue {
            banner.title = L10n.noValue
            banner.detailText = L10n.pleaseEnterAFieldValue

        } catch MiError.message(let message) {
            banner.detailText = message

        } catch MiError.alreadyExist(let str) {
            banner.detailText = L10n.alreadyExist(str)

        } catch MiError.noPasswordValue {
            banner.title = L10n.noValue
            banner.detailText = L10n.pleaseEnterAPassword

        } catch MiError.passwordMismatch {
            banner.detailText = L10n.yourPasswordAndConfirmationPasswordDoNotMatch

        } catch {
            banner.title = L10n.error
            banner.detailText = error.localizedDescription
        }

        return banner
    }

    func show() {
        banner.show()
    }
}
