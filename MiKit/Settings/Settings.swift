// Settings.swift
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

let kMiKeeContainerGroup = "group.me.maxep.mikee"

public enum AutoLock: Int {

    case always
    case fiveMinutes
    case tenMinutes
    case thirtyMinutes
    case oneHour
    case twelveHours
    case oneDay
    case never

    public var timeInterval: TimeInterval {
        switch self {
        case .always: return 0
        case .fiveMinutes: return 300
        case .tenMinutes: return 600
        case .thirtyMinutes: return 1800
        case .oneHour: return 3600
        case .twelveHours: return 43200
        case .oneDay: return 86400
        case .never: return Double.infinity
        }
    }

    public static let allValues: [AutoLock] = [.always,
                                               .fiveMinutes,
                                               .tenMinutes,
                                               .thirtyMinutes,
                                               .oneHour,
                                               .twelveHours,
                                               .oneDay,
                                               .never]

    public var localized: String {
        switch self {
        case .always: return L10n.always
        case .fiveMinutes: return L10n._5Minutes
        case .tenMinutes: return L10n._10Minutes
        case .thirtyMinutes: return L10n._30Minutes
        case .oneHour: return L10n._1Hour
        case .twelveHours: return L10n._12Hours
        case .oneDay: return L10n._1Day
        case .never: return L10n.donTAutoLock
        }
    }

}

public class Settings: NSObject {

    private struct UserDefaultsKeys {
        static var LastDatabase = "LastDatabase"
        static var AutoLockTime = "AutoLockTime"
        static var Biometrics = "Biometrics"
        static var LastEnterBackgroundDate = "LastEnterBackgroundDate"
    }

    static let settings = UserDefaults(suiteName: kMiKeeContainerGroup) ?? UserDefaults.standard

    public static var LastDatabase: Database? {
        guard let name = LastDatabaseName else { return nil }
        return Database.with(name: name)
    }

    public static var LastDatabaseName: String? {
        get { return settings.string(forKey: UserDefaultsKeys.LastDatabase) }
        set { settings.set(newValue, forKey: UserDefaultsKeys.LastDatabase) }
    }

    public static var AutoLock: AutoLock {
        get {
            guard
                let rawValue = settings.object(forKey: UserDefaultsKeys.AutoLockTime) as? Int,
                let autolock = MiKit.AutoLock(rawValue: rawValue)
            else { return .fiveMinutes }
            return autolock
        }
        set { settings.set(newValue.rawValue, forKey: UserDefaultsKeys.AutoLockTime) }
    }

    public static var Biometrics: Bool {
        get { return settings.bool(forKey: UserDefaultsKeys.Biometrics) }
        set { settings.set(newValue, forKey: UserDefaultsKeys.Biometrics) }
    }

    public static var LastEnterBackgroundDate: Date {
        get {
            guard
                let date = settings.object(forKey: UserDefaultsKeys.LastEnterBackgroundDate) as? Date
            else { return Date.distantPast }
            return date
        }
        set { settings.set(newValue, forKey: UserDefaultsKeys.LastEnterBackgroundDate) }
    }

}
