// Demo.swift
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
import KeePassKit

public class Demo: Database {

    public init?() {
        let bundle = Bundle(for: type(of: self))
        guard let file = bundle.url(forResource: "Demo", withExtension: "kdbx") else {
            return nil
        }
        super.init(name: "Demo", bookmark: nil, file: file, password: "demo", key: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func sync(_ completionHandler: ((Bool) -> Void)? = nil) throws { }

    override public func save(_ completionHandler: ((Bool) -> Void)? = nil) throws { }
}
