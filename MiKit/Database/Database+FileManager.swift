//
//  Database+FileManager.swift
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

import Foundation
import KeePassKit

var isAppExtension: Bool {
    return Bundle.main.executablePath?.contains(".appex") ?? false
}

extension Database {

    @available(iOSApplicationExtension, unavailable)
    @objc open func sync() throws {
        guard let tree = tree else { throw MiError.locked }
        let key = KPKCompositeKey(password: password, keyFileData: self.key?.data)!
        try sync(tree: tree, key: key)
    }

    @objc open func save() throws {
        guard let tree = tree else { throw MiError.locked }

        let key = KPKCompositeKey(password: password, keyFileData: self.key?.data)!

        let data = try KPKArchiver(tree: tree, key: key).archiveTree()
        try data.write(to: file)

        guard !isAppExtension, let bookmark = bookmark else { return }

        var isStale = false
        let url = try URL(resolvingBookmarkData: bookmark, bookmarkDataIsStale: &isStale)

        if isStale {
            self.bookmark = try url.bookmarkData()
            try archive()
        }

        try url.secure {
            try data.write(to: $0)
        }
    }

    @discardableResult
    public class func create(name: String, password: String, key file: String?) throws -> Database {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw MiError.createFile
        }

        let tree = KPKTree(name: name)

        var keyFileURL: URL?
        var keyFileData: Data?

        if let file = file {
            let name = file.hasSuffix(Key.Extension) ? file : "\(file).\(Key.Extension)"
            let data = NSData.kpk_generateKeyfileData(for: .kdbx)!
            let url = directory.appendingPathComponent(name)
            try data.write(to: url)

            keyFileData = data
            keyFileURL = url
        }

        let key = KPKCompositeKey(password: password, keyFileData: keyFileData)!
        let data = try KPKArchiver(tree: tree, key: key, format: .kdbx).archiveTree()
        let url = directory.appendingPathComponent("\(name).\(Database.Extension.kdbx)")
        try data.write(to: url)

        return try `import`(url, password: password, key: keyFileURL)
    }

    @discardableResult
    public class func `import`(_ url: URL, password: String? = nil, key file: URL? = nil) throws -> Database {

        var key: Database.Key?
        if let file = file {
            key = try Database.Key(contentsOf: file)
        }

        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier:kMiKeeContainerGroup)

        guard let file = container?.appendingPathComponent(url.lastPathComponent) else {
            throw MiError.unknown
        }

        let bookmark: Data = try url.secure {
            let data = try Data(contentsOf: $0)
            try data.write(to: file)
            return try url.bookmarkData()
        }

        let name = url.deletingPathExtension().lastPathComponent

        let db = Database(name: name, bookmark: bookmark, file: file, password: password, key: key)
        try db.archive()

        return db
    }

    public func export(to url: URL) throws {
        try save()

        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier:kMiKeeContainerGroup)

        guard let file = container?.appendingPathComponent(url.lastPathComponent) else {
            throw MiError.unknown
        }

        try url.secure {
            try FileManager.default.moveItem(at: file, to: $0)
            bookmark = try url.bookmarkData()
        }

        try archive()
    }

    @discardableResult
    public class func copy(contentsOf url: URL) throws -> Database {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw MiError.copyFile
        }

        let file = directory.appendingPathComponent(url.lastPathComponent)
        try FileManager.default.copyItem(at: url, to: file)
        return try `import`(file)
    }

    func sync(tree: KPKTree, key: KPKCompositeKey) throws {
        guard !isAppExtension, let bookmark = bookmark else { return }

        var isStale = false
        let url = try URL(resolvingBookmarkData: bookmark, bookmarkDataIsStale: &isStale)

        if isStale {
            self.bookmark = try url.bookmarkData()
            try archive()
        }

        try url.secure {
            let cloud = try KPKTree(contentsOf: url, key: key)
            tree.synchronize(with: cloud, mode: .synchronize, options: .matchGroupsByTitleOnly)

            let data = try KPKArchiver(tree: tree, key: key).archiveTree()
            try data.write(to: file)
            try data.write(to: $0)
        }
    }
}

extension URL {

    @discardableResult
    public func secure<T>(scope: (URL) throws -> T) rethrows -> T {
        let secured = startAccessingSecurityScopedResource()

        defer { if secured {
            stopAccessingSecurityScopedResource()
        }}

        return try scope(self)
    }
}
