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
    @State var copiedItemSearch: String = ""

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
                CopiedItemsList(searchText: copiedItemSearch)
                    .searchable(text: $copiedItemSearch)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
