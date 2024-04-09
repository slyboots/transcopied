//
//  Database.swift
//  Transcopied
//
//  Created by Dakota Lorance on 4/2/24.
//

import Dependencies
import Foundation
import SwiftData


enum DatabaseMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        BoardMigrationPlan.schemas+CopiedItemsMigrationPlan.schemas
    }

    static var stages: [MigrationStage] {
        BoardMigrationPlan.stages+CopiedItemsMigrationPlan.stages
    }
}

extension DependencyValues {
    var databaseService: Database {
        get { self[Database.self] }
        set { self[Database.self] = newValue }
    }
}

fileprivate let liveContext: ModelContext = {
    ModelContext(liveContainer)
}()

fileprivate let previewContext: ModelContext = {
    ModelContext(previewContainer)
}()

fileprivate let liveContainer: ModelContainer = {
    let schema = Schema([ CopiedItem.self, Board.self ])
#if DEBUG
    let cloudkitDB = ModelConfiguration.CloudKitDatabase.private("iCloud.transcopied.dev.1")
#else
    let cloudkitDB = ModelConfiguration.CloudKitDatabase.private("iCloud.transcopied.prod")
#endif
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, allowsSave: true, cloudKitDatabase: cloudkitDB)
    do {
        return try ModelContainer(for: schema, migrationPlan: DatabaseMigrationPlan.self, configurations: [config])
    }
    catch {
        
        fatalError("Could not create ModelContainer: \(error)")
    }
}()

private let previewContainer: ModelContainer = {
    let schema = Schema([ CopiedItem.self, Board.self ])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, allowsSave: true)
    do {
        return try ModelContainer(for: schema, migrationPlan: DatabaseMigrationPlan.self, configurations: [config])
    }
    catch {
        LOG.error("\(error)")
        fatalError("Could not create ModelContainer: \(error)")
    }
}()

struct Database {
    var context: @Sendable () -> ModelContext
    var container: @Sendable () -> ModelContainer
}


extension Database: DependencyKey {
    public static let liveValue: Database = Self(
        context: {liveContext},
        container: {liveContainer}
    )
}

extension Database: TestDependencyKey {
    public static var previewValue = Self.inMemory
    public static let testValue = Self.inMemory

    public static let inMemory: Database = Self(
        context: {previewContext},
        container: {previewContainer}
    )
}
