//
//  BoardVersions.swift
//  Transcopied
//
//  Created by Dakota Lorance on 4/7/24.
//

import CoreData
import Foundation
import SwiftData
import UIKit

enum BoardSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [Board.self]
    }

    @Model
    final class Board {
        var name: String = "Clips"

        init(name: String) {
            self.name = name
        }
    }
}

enum BoardSchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(2, 0, 0)
    static var models: [any PersistentModel.Type] {
        [Board.self]
    }

    @Model
    final class Board {
        var name: String = "Clips"
        @Relationship(deleteRule: .nullify, inverse: \CopiedItem.board)
        var copiedItems: [CopiedItem]? = [CopiedItem]()

        init(name: String, copiedItems: [CopiedItem] = []) {
            self.name = name
        }
    }
}

typealias Board = BoardSchemaV2.Board

enum BoardMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [BoardSchemaV1.self, BoardSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [
            Board__V1__V2
        ]
    }

    static let Board__V1__V2 = MigrationStage.lightweight(
        fromVersion: BoardSchemaV1.self,
        toVersion: BoardSchemaV2.self
    )

    static let Board__V2__CreateDefault = MigrationStage.custom(
        fromVersion: BoardSchemaV2.self,
        toVersion: BoardSchemaV2.self,
        willMigrate: nil,
        didMigrate: { ctx in
            let boardName = #Predicate<Board> { $0.name == "Copied" }
            do {
                try ctx.transaction {
                    var defaultBoardDescriptor = FetchDescriptor<Board>(predicate: boardName)
                    defaultBoardDescriptor.propertiesToFetch = [\.name]
                    let defaultCreated = try ctx.fetchCount(defaultBoardDescriptor) > 0
                    if !defaultCreated {
                        ctx.insert(Board(name: "Copied"))
                    }
                }
            } catch {
                print("Error Fetching Count: \(error)")
            }
        })
}
