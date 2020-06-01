// DatabasesViewController.swift
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
import MiKit

public protocol DatabasesViewControllerDelegate: class {
    func databasesViewController(_ databasesViewController: DatabasesViewController, didSelect database: Database)
}

public class DatabasesViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!

    public var databases: [Database]!

    public weak var delegate: DatabasesViewControllerDelegate?

    var indexPathForSelectKey: IndexPath?

    @IBOutlet weak var tableView: UITableView?

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Asset.background.color

        titleLabel.text = L10n.passwordDatabase
        backButton.setImage(Asset.forward.image, for: .normal)
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databases = Database.all()
    }

    @IBAction func pop(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension DatabasesViewController: UITableViewDelegate, UITableViewDataSource {

    // MARK: - TableView delegate

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let database = databases[indexPath.row]
        Settings.LastDatabaseName = database.name
        delegate?.databasesViewController(self, didSelect: database)
        navigationController?.popViewController(animated: true)
    }

    // MARK: - TableView data source

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return databases.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "db") as! DatabaseCell

        let database = databases[indexPath.row]
        cell.databaseLabel.text = database.name
        cell.keyField.text = database.key?.name

        return cell
    }

}

class DatabaseCell: UITableViewCell {

    @IBOutlet weak var databaseLabel: UILabel!
    @IBOutlet weak var keyField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()

        databaseLabel.textColor = Asset.grey.color
        keyField.textColor = Asset.purple.color
    }

}
