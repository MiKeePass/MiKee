// EntriesViewController.swift
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

public class EntriesViewController: UIViewController {

    @IBOutlet weak var titleField: TitleField!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    public var root: KPKGroup?

    private var entries: [KPKEntry]?

    public var credential: Credential!

    public weak var delegate: ExtensionDelegate?

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Asset.background.color

        definesPresentationContext = true

        closeButton.setImage(Asset.close.image, for: .normal)

        searchBar.tintColor = Asset.purple.color

        titleField.text = root?.title
        titleField.iconId = root?.iconId ?? 0

        tableView.register(EntryCell.nib, forCellReuseIdentifier: "entry")

        if let host = credential.url.host {
            filter(host: host)
        }
    }

    func filter(host: String) {
        let predicate = NSPredicate(format: "title CONTAINS[c] %@ OR url CONTAINS[c] %@ ", host, host)
        entries = root?.childEntries.filter { predicate.evaluate(with: $0) }

        tableView.reloadData()
    }

    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let destination = segue.destination as? EditEntryViewController {
            destination.delegate = delegate

            if let indexPath = tableView.indexPathForSelectedRow, indexPath.section > 0, let entry = entries?[indexPath.row] {
                credential.oldPassword = entry.password
                destination.entry = entry

            } else {

                let entry = KPKEntry()
                entry.title = credential.title
                entry.url = credential.url.absoluteString
                entry.username = credential.username
                entry.password = credential.password
                entry.notes = credential.notes

                credential.fields?.forEach {
                    let attribute = KPKAttribute(key: $0, value: $1)
                    entry.addCustomAttribute(attribute)
                }

                destination.entry = entry
            }

        } else if let destination = segue.destination as? SearchViewController {
            destination.searchableEntries = root?.searchableChildEntries
            destination.delegate = delegate
        }
    }

    @IBAction func done(_ sender: Any) {
        delegate?.viewController(didCancel: self)
    }

}

extension EntriesViewController: UITableViewDelegate, UITableViewDataSource {

    // MARK: Table delegate

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section > 0 else { return }
        guard let entry = entries?[indexPath.row] else { return }

        guard let token = entry.token else {
            delegate?.viewController(self, didSelect: entry)
            return
        }

        let alert = OTPAlertViewController(token: token) {
            self.delegate?.viewController(self, didSelect: entry)
        }

        present(alert, animated: true)
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section > 0 ? 16 : 0
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }

    // MARK: Table data source

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return entries?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "add")! as! AddEntryCell
            cell.titleLabel.text = L10n.newEntry

            if let host = credential.url.host {
                cell.descriptionLabel.text = L10n.addANewEntryFor(host)
            }
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "entry")! as! EntryCell
        cell.set(entry: entries?[indexPath.row])
        cell.disclosureIndicatorVisible = false
        return cell
    }

}

// MARK: Search

extension EntriesViewController: UISearchBarDelegate {

    public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        performSegue(withIdentifier: "search", sender: self)
        return false
    }

}

// MARK: Add Entry Cell

class AddEntryCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var indicatorImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.text = nil
        descriptionLabel.text = nil
        descriptionLabel.textColor = Asset.grey.color
        iconView.image = Asset.add.image
        indicatorImageView.image = Asset.disclosureIndicator.image
    }
}
