// AllEntriesViewController.swift
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
import KeePassKit

class AllEntriesViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    var root: KPKGroup? {
        didSet { entries = root?.childEntries }
    }

    private var entries: [KPKEntry]?

    private var newEntry: KPKEntry?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Asset.background.color
        searchBar.backgroundColor = Asset.background.color

        root = Database.current?.tree?.root

        addButton.setImage(Asset.add.image, for: .normal)
        backButton.setImage(Asset.back.image, for: .normal)
        searchBar.tintColor = Asset.purple.color

        tableView.register(EntryCell.nib, forCellReuseIdentifier: "entry")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        newEntry = nil
        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard Log.sessions > 5, !Log.get(.feedback) else { return }
        let feedback = FeedbackAlertViewController()
        present(feedback, animated: true)
        Log.event(.feedback)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EntryViewController {

            if let indexPath = tableView.indexPathForSelectedRow {
                destination.entry = entries?[indexPath.row]
            } else {
                destination.entry = newEntry
            }

        } else if let destination = segue.destination as? SearchNavigationController {
            destination.searchBar = searchBar
            destination.searchViewController?.searchableEntries = root?.searchableChildEntries
        }
    }

    @IBAction func toogle(_ sender: Any) {
        if let nvc = navigationController, nvc.viewControllers.count > 1 {
            nvc.popViewController(animated: true)
        } else if let nvc = splitViewController?.viewControllers.first as? UINavigationController {
            nvc.popViewController(animated: true)
        }
    }

}

extension AllEntriesViewController: UITableViewDelegate, UITableViewDataSource {

    // MARK: Table delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "entry", sender: self)
    }

    // MARK: Table data source

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entry")! as! EntryCell
        cell.set(entry: entries?[indexPath.row])

        cell.backgroundColor = Asset.background.color
        return cell
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        guard let entry = entries?[indexPath.row] else {
            return UISwipeActionsConfiguration()
        }

        let action = UIContextualAction(style: .destructive, title: nil) { (_, _, success) in

            do {

                try Database.current?.write {
                    entry.trashOrRemove()
                    self.entries?.remove(at: indexPath.row)
                }

                tableView.deleteRows(at: [indexPath], with: .automatic)

                UndoBanner(L10n.deleted) {
                    try? Database.current?.undo()
                    self.entries?.insert(entry, at: indexPath.row)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                }.show()

                success(true)

            } catch {
                error.show()
                success(false)
            }

        }

        action.image = UIImage.fontAwesomeIcon(name: .trashAlt, style: .regular, textColor: .white)
        action.backgroundColor = Asset.red.color

        return UISwipeActionsConfiguration(actions: [action])
    }
}

// MARK: Add Node

extension AllEntriesViewController {

    @IBAction func add(_ sender: Any) {

        guard let root = root else { return }

        var actions = [Action]()

        actions.append(title: "Entry") {
            self.newEntry = KPKEntry()
            self.newEntry?.add(to: root)

            self.performSegue(withIdentifier: "entry", sender: self)
        }

        let actionSheet = ActionSheet(actions: actions)
        present(actionSheet, animated: true)
    }

}

// MARK: Search

extension AllEntriesViewController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        performSegue(withIdentifier: "search", sender: self)
        return false
    }

}
