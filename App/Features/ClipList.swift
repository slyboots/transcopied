//
//  ClipListFeature.swift
//  Transcopied
//
//  Created by Dakota Lorance on 4/7/24.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct ClipList {
    @ObservableState
    struct State: Equatable {
        var board: String = ""
        var clips: [String] = []
    }

    enum Action: Equatable {
        case clipTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { _, _ in
            .none
        }
    }
}

struct ClipListView: View {
    let store: StoreOf<ClipList>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                ForEach(enumerating: viewStore.state.clips) { clip in
                    Text(clip)
                }
            }
            .listStyle(.inset)
        }
    }
}

#Preview {
    @Dependency(\.databaseService) var databaseService
    return NavigationSplitView(
        preferredCompactColumn: .constant(.content),
        sidebar: {EmptyView()},
        content: {
            ClipListView(
                store: Store(initialState: ClipList.State(
                    board: "Copied",
                    clips: [
                        "Test",
                        "123",
                        "456"
                    ]
                )) {
                    ClipList()
                        ._printChanges()
                }
            )
            .navigationTitle("Clips")
            .navigationBarTitleDisplayMode(.inline)
        },
        detail: { EmptyView() }
    )
    .modelContainer(databaseService.container())
}
