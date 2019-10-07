// ErrorBanner.swift
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

public class ErrorBanner: Banner {

    public convenience init() {
        let bundle = Bundle(for: type(of: self))
        self.init(nibName: "ErrorBanner", bundle: bundle)

        view.backgroundColor = Asset.red.color

        titleLabel.textColor = .white
        detailTextLabel?.textColor = .white

        actionButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 19, style: .solid)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.setTitle(String.fontAwesomeIcon(name: .times), for: .normal)

        barPosition = .topAttached
    }

}
