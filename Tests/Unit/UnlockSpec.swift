// UnlockSpec.swift
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

import Quick
import Nimble
import KeePassKit

@testable import MiKit

class UnlockSpec: QuickSpec {

    override func spec() {

        let bundle = Bundle(for: UnlockSpec.self)

        describe("Database") {

            context("with password") {

                let file = bundle.url(forResource: "test", withExtension: "kdbx")!

                it("should be unlocked") {

                    let database = Database(name: "Test", bookmark: nil, file: file, password: "test", key: nil)

                    var result: Result<KPKTree>?
                    database.open { result = $0 }

                    expect(result?.value).toEventuallyNot(beNil())
                }

                it("should fail to open") {

                    let database = Database(name: "Test", bookmark: nil, file: file, password: "wrong", key: nil)

                    var result: Result<KPKTree>?
                    database.open { result = $0 }

                    expect(result?.error).toEventuallyNot(be(MiError.wrongPasswordOrKey))
                }

            }

            context("with keyfile") {

                let file = bundle.url(forResource: "test_keyfile_nopass", withExtension: "kdbx")!
                let keyfile = bundle.url(forResource: "test", withExtension: "key")!

                it("should be unlocked") {

                    let key = try! Database.Key(contentsOf: keyfile)
                    let database = Database(name: "Test", bookmark: nil, file: file, password: nil, key: key)

                    var result: Result<KPKTree>?
                    database.open {
                        result = $0

                    }
                    expect(result?.value).toEventuallyNot(beNil())
                }

                it("should fail to open") {

                    let database = Database(name: "Test", bookmark: nil, file: file, password: "wrong", key: nil)

                    var result: Result<KPKTree>?
                    database.open { result = $0 }

                    expect(result?.error).toEventuallyNot(be(MiError.wrongPasswordOrKey))
                }

            }

            context("with password and keyfile") {

                let file = bundle.url(forResource: "test_keyfile", withExtension: "kdbx")!
                let keyfile = bundle.url(forResource: "test", withExtension: "key")!

                it("should be unlocked") {

                    let key = try! Database.Key(contentsOf: keyfile)
                    let database = Database(name: "Test", bookmark: nil, file: file, password: "test", key: key)

                    var result: Result<KPKTree>?
                    database.open { result = $0 }
                    expect(result?.value).toEventuallyNot(beNil())
                }

                it("should fail to open") {

                    let database = Database(name: "Test", bookmark: nil, file: file, password: "wrong", key: nil)

                    var result: Result<KPKTree>?
                    database.open { result = $0 }

                    expect(result?.error).toEventuallyNot(be(MiError.wrongPasswordOrKey))
                }

            }

        }
    }
}
