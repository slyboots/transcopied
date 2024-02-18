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
    @State private var pbm: PBoardManager = PBoardManager()
    @State private var currentBoard: Any? = nil
    @State private var currentUTI: String? = nil

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CopiedItem.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            cloudKitDatabase: ModelConfiguration.CloudKitDatabase.private("iCloud.Transcopied")
        )
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        }
        catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                CopiedItemsListContainer()
            }
            .environment(self.pbm)
            .onSceneActivate {
                // whenever the list view is shown
                // if we have new stuff in clip
                if self.pbm.canCopy {
                    // then save the data from the clipboard for use later
                    self.pbm.currentBoard = self.pbm.get()
                    self.pbm.currentUTI = self.pbm.uti()
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
