// GroupViewController.swift
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

class GroupViewController: UIViewController {

    @IBOutlet weak var titleField: TitleField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    var group: KPKGroup?

    private var newNode: KPKNode?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Asset.background.color

        titleField.set(group: group)
        titleField.addTarget(self, action: #selector(saveTitle(_:)), for: .save)
        titleField.addTarget(self, action: #selector(cancelTitle(_:)), for: .cancel)
        titleField.tintColor = Asset.purple.color
        if let group = group, group.title == nil || group.title.isEmpty {
            titleField.becomeFirstResponder()
        }

        addButton.setImage(Asset.add.image, for: .normal)
        if let group = group {
            addButton.isHidden = !group.isEditable || group.isTrash || group.isTrashed
        }

        backButton.setImage(Asset.back.image, for: .normal)

        searchBar.tintColor = Asset.purple.color

        tableView.register(GroupCell.nib, forCellReuseIdentifier: "group")
        tableView.register(EntryCell.nib, forCellReuseIdentifier: "entry")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        newNode = nil
        tableView.reloadData()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let destination = segue.destination as? GroupViewController {

            if let indexPath = tableView.indexPathForSelectedRow {
                destination.group = group!.groups[indexPath.row]
            } else {
                destination.group = newNode as? KPKGroup
            }

        } else if let destination = segue.destination as? EntryViewController {

            if let indexPath = tableView.indexPathForSelectedRow {
                destination.entry = group?.entries[indexPath.row]
            } else {
                destination.entry = newNode as? KPKEntry
            }

        } else if let destination = segue.destination as? SearchNavigationController {
            destination.searchBar = searchBar
            destination.searchViewController?.searchableEntries = group?.searchableChildEntries
        }
    }

    @IBAction func pop(_ sender: Any) {

        if let nvc = navigationController, nvc.viewControllers.count > 1 {
            nvc.popViewController(animated: true)
        } else if let nvc = splitViewController?.viewControllers.first as? UINavigationController {
            nvc.popViewController(animated: true)
        }
    }

    @objc func saveTitle(_ sender: TitleField) {
        group?.iconId = sender.iconId
        group?.title = sender.text

        try? Database.current?.save()
        sender.resignFirstResponder()
    }

    @objc func cancelTitle(_ sender: TitleField) {
        sender.set(group: group)
        sender.resignFirstResponder()
    }
}

extension GroupViewController: UITableViewDelegate, UITableViewDataSource {

    // MARK: Table delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch indexPath.section {
        case 0:
            performSegue(withIdentifier: "group", sender: self)
        default:
            performSegue(withIdentifier: "entry", sender: self)
        }
    }

    // MARK: Table data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let group = group else { return 0 }
        return section == 0 ? group.groups.count : group.entries.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "group")! as! GroupCell
            cell.set(group: group?.groups[indexPath.row])
            return cell

        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "entry")! as! EntryCell
            cell.set(entry: group?.entries[indexPath.row])
            return cell
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        guard let group = group else {
            return UISwipeActionsConfiguration()
        }

        let node: KPKNode
        if indexPath.section > 0 {
            node = group.entries[indexPath.row]
        } else {
            node = group.groups[indexPath.row]
        }

        let action = UIContextualAction(style: .destructive, title: nil) { (_, _, success) in

            do {
                try Database.current?.write {
                    node.isTrashed ? node.remove() : node.trashOrRemove()
                }

                tableView.deleteRows(at: [indexPath], with: .automatic)

                UndoBanner(L10n.deleted) {
                    try? Database.current?.undo()
                    tableView.insertRows(at: [indexPath], with: .automatic)
                }.show()

                success(true)

            } catch {
                error.show()
                success(false)
            }

        }

        action.image = UIImage.fontAwesomeIcon(name: .trashAlt, style: .regular)
        action.backgroundColor = Asset.red.color

        return UISwipeActionsConfiguration(actions: [action])
    }
}

// MARK: Add Node

extension GroupViewController {

    @IBAction func add(_ sender: Any) {
        guard let group = group else { return }

        var actions = [Action]()

        actions.append(title: "Entry") {
            self.newNode = KPKEntry()
            self.newNode?.add(to: group)

            self.performSegue(withIdentifier: "entry", sender: self)
        }

        actions.append(title: "Group") {
            self.newNode = KPKGroup()
            self.newNode?.add(to: group)

            self.performSegue(withIdentifier: "group", sender: self)
        }

        let actionSheet = ActionSheet(actions: actions)
        present(actionSheet, animated: true)
    }

}

// MARK: Search

extension GroupViewController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        performSegue(withIdentifier: "search", sender: self)
        return false
    }

}

// MARK: Title Field Extensions

extension TitleField {

    func set(group: KPKGroup?) {
        text = group?.title
        iconId = group?.iconId ?? 0

        customIcons = group?.tree?.metaData?.customIcons
        selectedIcon = group?.icon
    }

}
