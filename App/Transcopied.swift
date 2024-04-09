//
//  Transcopied.swift
//  Transcopied
//
//  Created by Dakota Lorance on 11/26/23.
//

import SwiftData
import SwiftUI
import ComposableArchitecture
import Dependencies


@main
struct Transcopied: App {
    @Dependency(\.databaseService) var databaseService

    @State private var pbm = PBManager()

    var body: some Scene {
        WindowGroup {
            AppContainerView(store: .init(initialState: AppContainer.State(), reducer: {
                AppContainer()
                    ._printChanges()
            }))
            // ClipEditorView(store: .init(initialState: ClipEditorFeature.State(), reducer: {ClipEditorFeature()._printChanges()}
            // CopiedItemListContainer()
        }
        .modelContainer(databaseService.container())
//            .pasteboardContext()
////            .onPasteboardContent {
////                withAnimation {
////                    // whenever the list view is shown if we have new stuff in clip
////                    // then save the data from the clipboard for use later
////                    Toolbox.saveClipboard(pbm: pbm, modelContext: sharedModelContainer.mainContext)
////                }
////            }
//            .onAppear(perform: {
//                withAnimation {
//                    Toolbox.saveClipboard(pbm: pbm, modelContext: sharedModelContainer.mainContext)
//                }
//            })
//            .onSceneActivate {
//                withAnimation {
//                    Toolbox.saveClipboard(pbm: pbm, modelContext: sharedModelContainer.mainContext)
//                }
//            }
//        }
//        .modelContainer(sharedModelContainer)
    }
}


#Preview {
    Group {
        @Dependency(\.databaseService) var databaseService
        let container = databaseService.container()
        AppContainerView(store: .init(initialState: AppContainer.State(), reducer: {
                AppContainer()
                    ._printChanges()
        }))
        .modelContainer(container)
    }
}
