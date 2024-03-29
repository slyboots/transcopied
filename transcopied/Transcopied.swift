//
//  Transcopied.swift
//  Transcopied
//
//  Created by Dakota Lorance on 11/26/23.
//

import SwiftData
import SwiftUI

@main
struct Transcopied: App {
    @State private var pbm = PBManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CopiedItem.self,
        ])
#if DEBUG
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            cloudKitDatabase: ModelConfiguration.CloudKitDatabase.private("iCloud.transcopied.dev.1")
        )
#else
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            cloudKitDatabase: ModelConfiguration.CloudKitDatabase.private("iCloud.transcopied.prod")
        )
#endif
        do {
            return try ModelContainer(
                for: schema,
//                migrationPlan: CopiedItemsMigrationPlan.self,
                configurations: [modelConfiguration]
            )
        }
        catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                CopiedItemListContainer()
            }
            .pasteboardContext()
            .onPasteboardContent {
                // whenever the list view is shown
                // if we have new stuff in clip
                if pbm.canCopy {
                    // then save the data from the clipboard for use later
                    pbm.incomingBuffer = pbm.get()
                }
            }
            .onSceneActivate {
                // whenever the list view is shown
                // if we have new stuff in clip
                if pbm.canCopy {
                    // then save the data from the clipboard for use later
                    pbm.incomingBuffer = pbm.get()
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
