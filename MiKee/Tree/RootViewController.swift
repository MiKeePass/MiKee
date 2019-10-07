// RootViewController.swift
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
import FontAwesome_swift

class RootViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var addGroupButton: UIButton!
    @IBOutlet weak var lockButton: UIButton!

    public var root: KPKGroup?

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Asset.background.color

        let tree = Database.current?.tree
        root = tree?.root

        settingsButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 17, style: .solid)
        settingsButton.setTitle(String.fontAwesomeIcon(name: .cog), for: .normal)
        settingsButton.setTitleColor(Asset.purple.color, for: .normal)

        addGroupButton.setImage(Asset.add.image, for: .normal)

        lockButton.backgroundColor = Asset.largeButtonBackground.color
        lockButton.setTitle(L10n.lock, for: .normal)
        lockButton.setTitleColor(Asset.textColor.color, for: .normal)

        tableView.register(GroupCell.nib, forCellReuseIdentifier: "group")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tree = Database.current?.tree
        titleLabel.text = tree?.metaData?.databaseName
    }

    @IBAction func lock(_ sender: Any) {

        Database.current?.password = nil
        try? Database.current?.archive()
        Database.current?.lock()

        splitViewController?.dismiss(animated: true)
    }

     // MARK: - Navigation

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nvc = segue.destination as? UINavigationController else { return }

        if let destination = nvc.viewControllers.first as? GroupViewController,
            let indexPath = tableView.indexPathForSelectedRow {

            destination.group = root?.groups[indexPath.row]
        }
     }

    // MARK: Table delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 0 {
            performSegue(withIdentifier: "all", sender: self)
        } else {
            performSegue(withIdentifier: "group", sender: self)
        }
    }

    // MARK: Table data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return root?.groups.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "group") as! GroupCell

        if indexPath.section == 0 {
            cell.set(group: root)
            cell.titleField.text = L10n.all
        } else {
            cell.set(group: root?.groups[indexPath.row])
        }

        return cell
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        guard indexPath.section > 0, let group = root?.groups[indexPath.row], !group.isTrash else {
            return UISwipeActionsConfiguration()
        }

        let action = UIContextualAction(style: .destructive, title: nil) { (_, _, success) in

            do {
                try Database.current?.write {
                    group.trashOrRemove()
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

extension RootViewController {

    @IBAction func add(_ sender: Any) {

//        guard let root = root else { return }

        var actions = [Action]()

        actions.append(title: "Group") {
//            let group = KPKGroup()
//            group.add(to: root)
//            tvc.show(group)
        }

        let actionSheet = ActionSheet(actions: actions)
        present(actionSheet, animated: true)
    }

}
