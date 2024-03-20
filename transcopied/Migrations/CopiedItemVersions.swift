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
    // initial structure
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [CopiedItem.self]
    }

    enum CopiedItemType: String, Codable {
        case text = "TXT"
        case url = "URL"
        case img = "IMG"
        case file = "FILE"
    }

    @Model
    final class CopiedItem {
        var title: String?
        var content: String?
        var timestamp: Date = Date(timeIntervalSinceNow: TimeInterval(0))
        var type: String = CopiedItemType.text.rawValue

        init(content: String?, title: String?, timestamp: Date, type: CopiedItemType) {
            self.content = content
            self.timestamp = timestamp
            self.type = type.rawValue
            self.title = title
        }
    }
}

enum CopiedItemSchemaV1_5: VersionedSchema {
    // use intermediary column to migrate from string content
    // over to Data content columns
    static var versionIdentifier: Schema.Version = .init(1, 5, 0)
    static var models: [any PersistentModel.Type] {
        [CopiedItem.self]
    }

    enum CopiedItemType: String, Codable {
        case text = "TXT"
        case url = "URL"
        case img = "IMG"
        case file = "FILE"
    }

    @Model
    final class CopiedItem {
        var title: String?
        var content: String?
        var timestamp: Date = Date(timeIntervalSinceNow: TimeInterval(0))
        var type: String = CopiedItemType.text.rawValue

        var dummyColumn: Data = Data()

        init(content: String?, title: String?, timestamp: Date, type: CopiedItemType) {
            self.content = content
            self.timestamp = timestamp
            self.type = type.rawValue
            self.title = title
        }
    }
}

enum CopiedItemSchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(2, 0, 0)
    static var models: [any PersistentModel.Type] {
        [CopiedItem.self]
    }

    @Model
    final class CopiedItem {
        var uid: String = "00000000-0000-0000-0000-000000000000"
        var title: String = ""
        var type: String = ""
        var timestamp: Date = Date(timeIntervalSince1970: .zero)

        var content: String = ""
        @Attribute(.externalStorage)
        var data: Data = Data()

        @Transient var text: String?
        @Transient var url: URL?
        @Transient var file: Data?
        @Transient var image: UIImage?

        init(content: Any, type: PasteboardContentType, title: String = "", timestamp: Date?) {
            switch type {
                case .image:
                    let I = (content as! UIImage)
                    self.uid = hashString(data: I.pngData()!)
                    self.type = PasteboardContentType.image.rawValue
                    self.data = I.pngData()!
                case .file:
                    let D = (content as! Data)
                    self.uid = hashString(data: D)
                    self.type = PasteboardContentType.file.rawValue
                    self.data = Data(D)
                case .text:
                    let S = (content as! String)
                    self.uid = hashString(data: Data(S.utf8))
                    self.type = PasteboardContentType.text.rawValue
                    self.content = S
                case .url:
                    let U = (content as! URL)
                    self.uid = hashString(data: Data(U.absoluteString.utf8))
                    self.type = PasteboardContentType.url.rawValue
                    self.content = U.absoluteString
            }
            if !self.content.isEmpty {
                self.timestamp = timestamp ?? Date(timeIntervalSinceNow: TimeInterval(0))
            }
            self.title = title
        }
    }
}

enum CopiedItemSchemaV3: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(3, 0, 0)
    static var models: [any PersistentModel.Type] {
        [CopiedItem.self]
    }

    @Model
    final class CopiedItem {
        var uid: String = "00000000-0000-0000-0000-000000000000"
        var title: String = ""
        var type: String = ""
        var timestamp: Date = Date(timeIntervalSince1970: .zero)

        var content: String = ""
        @Attribute(.externalStorage)
        var data: Data = Data()

        @Transient var text: String?
        @Transient var url: URL?
        @Transient var file: Data?
        @Transient var image: UIImage?

        init(content: Any, type: PasteboardContentType, title: String = "", timestamp: Date?) {
            switch type {
                case .image:
                    let I = (content as! UIImage)
                    self.uid = hashString(data: I.pngData()!)
                    self.type = PasteboardContentType.image.rawValue
                    self.data = I.pngData()!
                    self.content = ""
                case .file:
                    let D = (content as! Data)
                    self.uid = hashString(data: D)
                    self.type = PasteboardContentType.file.rawValue
                    self.data = Data(D)
                    self.content = ""
                case .text:
                    let S = (content as! String)
                    self.uid = hashString(data: Data(S.utf8))
                    self.type = PasteboardContentType.text.rawValue
                    self.content = S
                    self.data = Data()
                case .url:
                    let U = (content as! URL)
                    self.uid = hashString(data: Data(U.absoluteString.utf8))
                    self.type = PasteboardContentType.url.rawValue
                    self.content = U.absoluteString
                    self.data = Data()
            }
            if !self.content.isEmpty {
                self.timestamp = timestamp ?? Date(timeIntervalSinceNow: TimeInterval(0))
            }
            self.title = title
        }
    }
}

enum CopiedItemsMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [CopiedItemSchemaV1.self, CopiedItemSchemaV2.self, CopiedItemSchemaV3.self]
    }

    static var stages: [MigrationStage] {
        [
            //            V1__V2,
//            V2__V3
        ]
    }

    static let V1__V1_5 = MigrationStage.custom(
        fromVersion: CopiedItemSchemaV1.self,
        toVersion: CopiedItemSchemaV2.self,
        willMigrate: { _ in

        },
        didMigrate: { context in
            let copieditems = try context.fetch(FetchDescriptor<CopiedItemSchemaV1_5.CopiedItem>())
            for item in copieditems {
                if item.content != nil {
                    item.dummyColumn = Data(item.content!.utf8)
                }
            }
        }
    )

    static let V1__V2 = MigrationStage.lightweight(
        fromVersion: CopiedItemSchemaV1.self,
        toVersion: CopiedItemSchemaV2.self
    )
    static let V2__V3 = MigrationStage.lightweight(
        fromVersion: CopiedItemSchemaV2.self,
        toVersion: CopiedItemSchemaV3.self
    )
//    static let V2__v3 = MigrationStage.custom(
//        fromVersion: CopiedItemSchemaV2.self,
//        toVersion: CopiedItemSchemaV3.self,
//        willMigrate: { context in
//
//        },
//        didMigrate: { context in
//            let copieditems = try context.fetch(FetchDescriptor<CopiedItemSchemaV1_5.CopiedItem>())
//            for item in copieditems {
//                if item.content != nil {
//                    item.dummyColumn = Data(item.content!.utf8)
//                }
//            }
//        }
//    )
}
