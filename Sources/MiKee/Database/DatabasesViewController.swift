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
import KeePassKit
import MiKit

protocol DatabasesViewControllerDelegate: AnyObject {
    func databasesViewController(_ databasesViewController: DatabasesViewController, didSelect database: Database)
    func databasesViewController(_ databasesViewController: DatabasesViewController, didRemove database: Database)
}

class DatabasesViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var importButton: UIButton!

    var databases: [Database]!

    weak var delegate: DatabasesViewControllerDelegate?

    var indexPathForSelectKey: IndexPath?

    @IBOutlet weak var tableView: UITableView?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Asset.background.color

        titleLabel.text = L10n.passwordDatabase
        backButton.setImage(Asset.forward.image, for: .normal)

        createButton.setTitle(L10n.create, for: .normal)
        createButton.setTitleColor(Asset.textColor.color, for: .normal)
        createButton.backgroundColor = Asset.largeButtonBackground.color

        importButton.setTitle(L10n.import, for: .normal)
        importButton.setTitleColor(Asset.textColor.color, for: .normal)
        importButton.backgroundColor = Asset.largeButtonBackground.color

        databases = Database.all()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let destination = segue.destination as? CreateDatabaseViewController {
            destination.delegate = self

        } else if let destination = segue.destination as? KeysViewController {
            destination.delegate = self
        }
    }

    @IBAction func importDatabase(_ sender: Any) {
        let browser = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .open)
        browser.delegate = self
        present(browser, animated: true)
    }

    @IBAction func pop(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension DatabasesViewController: UITableViewDelegate, UITableViewDataSource {

    // MARK: - TableView delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let database = databases[indexPath.row]
        Settings.LastDatabaseName = database.name
        delegate?.databasesViewController(self, didSelect: database)
        navigationController?.popViewController(animated: true)
    }

    // MARK: - TableView data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return databases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "db") as! DatabaseCell

        let database = databases[indexPath.row]
        cell.databaseLabel.text = database.name
        cell.keyField.text = database.key?.name

        cell.selectKey = { _ in
            self.indexPathForSelectKey = indexPath
            self.performSegue(withIdentifier: "key", sender: self)
        }

        cell.removeKey = { cell in
            safely {
                database.key = nil
                cell.keyField.text = nil
                try database.archive()
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let action = UIContextualAction(style: .destructive, title: nil) { (_, _, success) in

            let database = self.databases[indexPath.row]

            try? database.remove()
            self.databases.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)

            let selected = Settings.LastDatabaseName == database.name
            if selected { Settings.LastDatabaseName = nil }

            self.delegate?.databasesViewController(self, didRemove: database)

            UndoBanner("Deleted") {
                try? database.archive()
                self.databases.append(database)
                tableView.insertRows(at: [indexPath], with: .automatic)

                if selected {
                    Settings.LastDatabaseName = database.name
                    self.delegate?.databasesViewController(self, didSelect: database)
                }
            }.show()

            success(true)
        }

        action.image = UIImage.fontAwesomeIcon(name: .trashAlt, style: .solid, textColor: .white)
        action.backgroundColor = UIColor(named: "Red")

        return UISwipeActionsConfiguration(actions: [action])
    }

}

extension DatabasesViewController: UIDocumentPickerDelegate {

    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        safely {
            guard let url = urls.first else { throw MiError.openFile }

            let database = try Database.import(url)

            if let index = databases.firstIndex(where: { $0.name == database.name }) {
                databases[index] = database
                tableView?.reloadData()
                return
            }

            tableView?.beginUpdates()
            let indexPath = IndexPath(row: databases.count, section: 0)
            tableView?.insertRows(at: [indexPath], with: .automatic)
            databases?.append(database)
            tableView?.endUpdates()

            tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {

    }

}

extension DatabasesViewController: KeysViewControllerDelegate {

    func keysViewController(_ keysViewController: KeysViewController, didSelect key: Database.Key) {
        guard let indexPath = indexPathForSelectKey else { return }

        safely {
            let database = databases[indexPath.row]
            database.key = key
            try database.archive()

            if let cell = tableView?.cellForRow(at: indexPath) as? DatabaseCell {
                cell.keyField.text = key.name
            }
        }
    }

    func keysViewController(_ keysViewController: KeysViewController, didRemoveWith name: String) {

        for (row, database) in databases.enumerated() {
            guard database.key?.name == name else { continue }

            database.key = nil
            try? database.archive()

            let indexPath = IndexPath(row: row, section: 0)
            if let cell = tableView?.cellForRow(at: indexPath) as? DatabaseCell {
                cell.keyField.text = nil
            }
        }
    }

}

extension DatabasesViewController: CreateDatabaseViewControllerDelegate {

    func createDatabaseViewController(_ createDatabaseViewController: CreateDatabaseViewController, didCreate database: Database, tree: KPKTree?) {
        guard let vc = navigationController?.viewControllers.first as? OpenViewController, let tree = tree else {
            return createDatabaseViewControllerDidCancel(createDatabaseViewController)
        }

        vc.open(tree: tree, animated: true) {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

    func createDatabaseViewControllerDidCancel(_ createDatabaseViewController: CreateDatabaseViewController) {
        navigationController?.popToRootViewController(animated: true)
    }

}
