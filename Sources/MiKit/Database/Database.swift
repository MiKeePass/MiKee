// Database.swift
//
// Created by Maxime Epain on 09/09/2017.
// Copyright © 2017 Maxime Epain. All rights reserved.
//
// The methods and techniques described herein are considered trade secrets
// and/or confidential. Reproduction or distribution, in whole or in part,
// is forbidden except by express written permission of Maxime Epain.
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import Resources
import KeePassKit

open class Database: NSObject, NSCoding {

    static public internal(set) var current: Database?

    public struct Extension {
        static public let kdb = "kdb"
        static public let kdbx = "kdbx"
    }

    public struct Key {

        static public let Extension = "key"

        public let name: String

        public let data: Data

        public init(name: String, data: Data) {
            self.name = name
            self.data = data
        }

        @discardableResult
        public init(contentsOf url: URL) throws {
            self.name = url.lastPathComponent
            self.data = try Data(contentsOf: url)
        }
    }

    public let name: String

    public let file: URL

    public var password: String?

    public var key: Key?

    public var bookmark: Data?

    public internal(set) var tree: KPKTree?

    lazy var undoManager = UndoManager()

    init(name: String, bookmark: Data?, file: URL, password: String? = nil, key: Key? = nil) {
        self.name = name
        self.bookmark = bookmark
        self.file = file
        self.password = password
        self.key = key
    }

    public func set(password: String) throws {
        guard let tree = tree else { throw MiError.locked }

        let key = KPKCompositeKey(password: password, keyFileData: self.key?.data)!
        let data = try KPKArchiver(tree: tree, key: key, format: .kdbx).archiveTree()
        try data.write(to: file)

        try url()?.secure {
            try data.write(to: $0)
        }

        self.password = password
        try archive()
    }

    public func set(key: Key?) throws {
        guard let tree = tree else { throw MiError.locked }

        let compositeKey = KPKCompositeKey(password: password, keyFileData: key?.data)!
        let data = try KPKArchiver(tree: tree, key: compositeKey, format: .kdbx).archiveTree()
        try data.write(to: file)

        try url()?.secure {
            try data.write(to: $0)
        }

        self.key = key
        try archive()
    }

    public func url() throws -> URL? {
        guard let bookmark = bookmark else { return nil }
        var isStale = false
        return try URL(resolvingBookmarkData: bookmark, bookmarkDataIsStale: &isStale)
    }

    public func set(url: URL) throws {
        try url.secure {
            bookmark = try $0.bookmarkData()
        }
        try archive()
    }

    public var hasPassword: Bool {
        return password != nil
    }

    public func open(_ completionHandler: @escaping ResultClosure<KPKTree>) {

        DispatchQueue.global(qos: .background).async {

            let result = Result { () -> KPKTree in
                let key = KPKCompositeKey(password: self.password, keyFileData: self.key?.data)!

                let tree = try KPKTree(contentsOf: self.file, key: key)
                tree.delegate = self

                try self.archive()

                try self.sync(tree: tree, key: key)
                self.tree = tree
                Database.current = self

                return tree
            }

            DispatchQueue.main.async { completionHandler(result) }
        }
    }

    public func lockIfNeeded() -> Bool {
        guard -Settings.LastEnterBackgroundDate.timeIntervalSinceNow > Settings.AutoLock.timeInterval else { return false }
        lock()
        return true
    }

    public func lock() {
        tree = nil
        Database.current = nil
    }

    // MARK: Coding

    public required init?(coder aDecoder: NSCoder) {

        guard let name = aDecoder.decodeObject(forKey: "name") as? String,
            let bookmark = aDecoder.decodeObject(forKey: "bookmark") as? Data,
            let file = aDecoder.decodeObject(forKey: "file") as? URL
        else { return nil }

        self.name = name
        self.bookmark = bookmark
        self.file = file

        password = aDecoder.decodeObject(forKey: "password") as? String

        if let name = aDecoder.decodeObject(forKey: "key.name") as? String,
            let data = aDecoder.decodeObject(forKey: "key.data") as? Data {
            key = Key(name: name, data: data)
        }
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(bookmark, forKey: "bookmark")
        aCoder.encode(file, forKey: "file")
        aCoder.encode(password, forKey: "password")
        aCoder.encode(key?.name, forKey: "key.name")
        aCoder.encode(key?.data, forKey: "key.data")
    }

    // MARK: Transaction
    public func beginTransaction() {
        undoManager.beginUndoGrouping()
    }

    public func endTransaction() throws {
        undoManager.endUndoGrouping()
        try save()
    }

    public func write(_ transaction:(() throws -> Void)) throws {
        beginTransaction()
        try transaction()
        try endTransaction()
    }

    public func undo() throws {
        undoManager.undo()
        try save()
    }
}

extension Database: KPKTreeDelegate {

    public func undoManager(for tree: KPKTree) -> UndoManager {
        return undoManager
    }
}

extension KPKTree {

    convenience init(name: String) {
        self.init()
        metaData?.databaseName = name
        metaData?.keyDerivationParameters = KPKArgon2KeyDerivation.defaultParameters()
        metaData?.cipherUUID = KPKChaCha20Cipher().uuid

        let root = createGroup(nil)
        root.title = L10n.general
        root.iconId = Int(KPKIconType.folder.rawValue)
        self.root = root

        var group = createGroup(root)
        group.title = L10n.apple
        group.iconId = Int(KPKIconType.apple.rawValue)
        group.add(to: root)

        group = createGroup(root)
        group.title = L10n.internet
        group.iconId = Int(KPKIconType.packageNetwork.rawValue)
        group.add(to: root)

        group = createGroup(root)
        group.title = L10n.email
        group.iconId = Int(KPKIconType.email.rawValue)
        group.add(to: root)

        group = createGroup(root)
        group.title = L10n.banking
        group.iconId = Int(KPKIconType.percentage.rawValue)
        group.add(to: root)
    }
}
