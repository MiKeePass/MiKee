// KeysViewController.swift
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

//
//  *.swift
//  *
//
//  Created by Maxime Epain on *.
//  Copyright © * * *. All rights reserved.
//

import UIKit
import Resources
import MiKit

public protocol KeysViewControllerDelegate: class {
    func keysViewController(_ keysViewController: KeysViewController, didSelect key: Database.Key)
    func keysViewController(_ keysViewController: KeysViewController, didRemoveWith name: String)
}

public class KeysViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var importButton: UIButton!

    public weak var delegate: KeysViewControllerDelegate?

    var files = [URL]()

    @IBOutlet weak var tableView: UITableView?

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Asset.background.color

        titleLabel.text = L10n.keyFiles
        closeButton.setImage(Asset.close.image, for: .normal)

        importButton.setTitle(L10n.import, for: .normal)
        importButton.setTitleColor(.black, for: .normal)
        importButton.backgroundColor = Asset.largeButtonBackground.color

        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        files = keys(in: directory)
    }

    private func keys(in directory: URL) -> [URL] {
        var files = [URL]()

        if let urls = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) {
            for url in urls {

                if let res = try? url.resourceValues(forKeys: [.isDirectoryKey]), let isDirectory = res.isDirectory, isDirectory {
                    files += keys(in: url)
                } else if url.pathExtension == "key" {
                    files.append(url)
                }
            }
        }

        return files
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func importKey(_ sender: Any) {
        let browser = UIDocumentPickerViewController(documentTypes: ["com.apple.keynote.key"], in: .import)
        browser.delegate = self
        present(browser, animated: true)
    }

    @IBAction func dismiss(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }

}

extension KeysViewController: UITableViewDelegate, UITableViewDataSource {

    // MARK: - TableView delegate

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        safely {
            let file = self.files[indexPath.row]
            let data = try Data(contentsOf: file)
            let name = file.lastPathComponent
            let key = Database.Key(name: name, data: data)
            delegate?.keysViewController(self, didSelect: key)
            dismiss(nil)
        }
    }

    // MARK: - TableView data source

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "key") as! KeyCell
        cell.keyLabel.text = files[indexPath.row].lastPathComponent
        return cell
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return self.tableView(tableView, leadingSwipeActionsConfigurationForRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let action = UIContextualAction(style: .destructive, title: nil) { (_, _, success) in

            do {

                let file = self.files[indexPath.row]
                let data = try Data(contentsOf: file)

                try FileManager.default.removeItem(at: file)
                self.files.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)

                UndoBanner(L10n.deleted) {
                    try? data.write(to: file)
                    self.files.append(file)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                }.show()

                success(true)
            } catch {
                error.show()
                success(false)
            }
        }

        action.image = UIImage.fontAwesomeIcon(name: .trashAlt, style: .solid, textColor: .white)
        action.backgroundColor = Asset.red.color

        return UISwipeActionsConfiguration(actions: [action])
    }

}

extension KeysViewController: UIDocumentPickerDelegate {

    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        safely {
            guard
                let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
                let url = urls.first
            else { throw MiError.copyFile }

            let file = directory.appendingPathComponent(url.lastPathComponent)
            try FileManager.default.copyItem(at: url, to: file)
            let key = try Database.Key(contentsOf: file)
            delegate?.keysViewController(self, didSelect: key)

            dismiss(nil)
        }
    }

    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {

    }

}
