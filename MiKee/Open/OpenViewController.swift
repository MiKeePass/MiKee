// OpenViewController.swift
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
import MiKit

class OpenViewController: LockViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        keyField?.addTarget(self, action: #selector(selectKey(_:)), for: .add)
        keyField?.addTarget(self, action: #selector(removeKey(_:)), for: .clear)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? KeysViewController {
            destination.delegate = self
        } else if let destination = segue.destination as? DatabasesViewController {
            destination.delegate = self
        }
    }

    override func open(tree: KPKTree, animated: Bool, completion: (() -> Void)? = nil) {
        let storyboard = UIStoryboard(name: "Tree", bundle: nil)
        guard let vc = storyboard.instantiateInitialViewController() else { return }

        vc.modalPresentationStyle = .fullScreen
        vc.transitioningDelegate = self
        present(vc, animated: animated, completion: completion)
    }

    @IBAction func selectDatabase(_ sender: Any) {
        performSegue(withIdentifier: "db", sender: self)
    }

    @objc func selectKey(_ sender: Any) {
        performSegue(withIdentifier: "key", sender: self)
    }

    @objc func removeKey(_ sender: Any) {
        guard let database = database else { return }

        safely {
            database.key = nil
            keyField?.text = nil
            try database.archive()
        }
    }

}

extension OpenViewController {

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == keyField {
            performSegue(withIdentifier: "key", sender: self)
            return false
        }
        return true
    }
}

extension OpenViewController: DatabasesViewControllerDelegate {

    func databasesViewController(_ databasesViewController: DatabasesViewController, didSelect database: Database) {
        self.database = database
    }

    func databasesViewController(_ databasesViewController: DatabasesViewController, didRemove database: Database) {
        guard database.name == self.database?.name else { return }
        self.database = nil
    }
}

extension OpenViewController: KeysViewControllerDelegate {

    func keysViewController(_ keysViewController: KeysViewController, didSelect key: Database.Key) {
        guard let database = database else { return }

        safely {
            database.key = key
            keyField?.text = key.name
            try database.archive()
        }
    }

    func keysViewController(_ keysViewController: KeysViewController, didRemoveWith name: String) {
        guard let database = database, database.key?.name == name else { return }

        safely {
            database.key = nil
            keyField?.text = nil
            try database.archive()
        }
    }

}
