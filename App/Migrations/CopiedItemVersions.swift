//
//  CopiedItemVersions.swift
//  Transcopied
//
//  Created by Dakota Lorance on 3/3/24.
//

import CoreData
import Foundation
import SwiftData
import UIKit

enum CopiedItemSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [CopiedItem.self]
    }

    @Model
    final class CopiedItem {
        var uid: String = "00000000-0000-0000-0000-000000000000"
        var title: String = ""
        var type: String = ""
        var timestamp = Date(timeIntervalSince1970: .zero)
        var content: String = ""
        @Attribute(.externalStorage)
        var data = Data()

        init(content: Any, type: PasteboardContentType, title: String = "", timestamp: Date? = nil) {
            switch type {
                case .image:
                    let I = (content as! UIImage)
                    self.uid = hashString(data: I.pngData()!)
                    self.type = PasteboardContentType.image.rawValue
                    self.data = I.pngData()!
                    self.title = title
                case .url:
                    let U = (content as! URL)
                    self.uid = hashString(data: Data(U.absoluteString.utf8))
                    self.type = PasteboardContentType.url.rawValue
                    self.content = U.absoluteString
                    self.title = title.isEmpty ? (U.host() ?? U.formatted(.url)) : title
                case .text:
                    let S = (content as! String)
                    self.uid = hashString(data: Data(S.utf8))
                    self.type = PasteboardContentType.text.rawValue
                    self.content = S
                    self.title = title
                case .file:
                    let D = (content as! Data)
                    self.uid = hashString(data: D)
                    self.type = PasteboardContentType.file.rawValue
                    self.data = Data(D)
                    self.title = title
            }
            if !self.content.isEmpty || !data.isEmpty {
                self.timestamp = timestamp ?? Date(timeIntervalSinceNow: 0)
            }
        }
    }
}

enum CopiedItemSchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [CopiedItem.self]
    }

    @Model
    final class CopiedItem {
        var board: Board? = nil
        var uid: String = "00000000-0000-0000-0000-000000000000"
        var title: String = ""
        var type: String = ""
        var timestamp = Date(timeIntervalSince1970: .zero)
        var content: String = ""
        @Attribute(.externalStorage)
        var data = Data()

        init(content: Any, type: PasteboardContentType, title: String = "", timestamp: Date? = nil, board: Board? = nil) {
            self.board = board
            switch type {
                case .image:
                    let I = (content as! UIImage)
                    self.uid = hashString(data: I.pngData()!)
                    self.type = PasteboardContentType.image.rawValue
                    self.data = I.pngData()!
                    self.title = title
                case .url:
                    let U = (content as! URL)
                    self.uid = hashString(data: Data(U.absoluteString.utf8))
                    self.type = PasteboardContentType.url.rawValue
                    self.content = U.absoluteString
                    self.title = title.isEmpty ? (U.host() ?? U.formatted(.url)) : title
                case .text:
                    let S = (content as! String)
                    self.uid = hashString(data: Data(S.utf8))
                    self.type = PasteboardContentType.text.rawValue
                    self.content = S
                    self.title = title
                case .file:
                    let D = (content as! Data)
                    self.uid = hashString(data: D)
                    self.type = PasteboardContentType.file.rawValue
                    self.data = Data(D)
                    self.title = title
            }
            if !self.content.isEmpty || !data.isEmpty {
                self.timestamp = timestamp ?? Date(timeIntervalSinceNow: 0)
            }
        }
    }
}

typealias CopiedItem = CopiedItemSchemaV2.CopiedItem

enum CopiedItemsMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [CopiedItemSchemaV1.self, CopiedItemSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [
            CopiedItem__V1__V2
        ]
    }

    static let CopiedItem__V1__V2 = MigrationStage.lightweight(
        fromVersion: CopiedItemSchemaV1.self,
        toVersion: CopiedItemSchemaV2.self
    )
}
