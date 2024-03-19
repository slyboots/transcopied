//
//  TranscopiedApp.swift
//  Transcopied
//
//  Created by Dakota Lorance on 11/26/23.
//

import SwiftData
import SwiftUI

@main
struct Transcopied: App {
    @State private var pbm: PBManager = PBManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CopiedItem.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            cloudKitDatabase: ModelConfiguration.CloudKitDatabase.private("transcopied.dev.1")
        )
        do {
            return try ModelContainer(
                for: schema,
//                migrationPlan: .none,
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
            .onSceneActivate {
                // whenever the list view is shown
                // if we have new stuff in clip
                if self.pbm.canCopy {
                    // then save the data from the clipboard for use later
                    self.pbm.incomingBuffer = self.pbm.get()
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
