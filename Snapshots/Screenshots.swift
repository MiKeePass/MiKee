// Screenshots.swift
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
import SimulatorStatusMagic

class Screenshots: QuickSpec {

    override func spec() {

        describe("Fastlane") {

            it("screenshots") {

                self.continueAfterFailure = false

                let app = XCUIApplication()
                setupSnapshot(app)

                app.launch()

                let statusBarManager = SDStatusBarManager.sharedInstance()
                statusBarManager?.enableOverrides()

                snapshot("1-LockScreen")

                let passField = app.secureTextFields["pass_field"]
                passField.tap()
                passField.typeText("demo")
                app.buttons["unlock_button"].tap()
                expect(app.staticTexts["All"].exists).toEventually(beTrue(), timeout: 60)

                snapshot("2-AllScreen")

                app.tables.staticTexts["My MacBook"].tap()
                expect(app.textFields["My MacBook"].exists).toEventually(beTrue())

                snapshot("3-EntryScreen")

                SDStatusBarManager.sharedInstance().disableOverrides()
            }
        }
    }
}
