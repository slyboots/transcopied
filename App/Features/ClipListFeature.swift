//
//  ClipListFeature.swift
//  Transcopied
//
//  Created by Dakota Lorance on 4/7/24.
//

import Foundation
import ComposableArchitecture
import SwiftUI


@Reducer
struct ClipListFeature {
    @ObservableState
    struct State: Equatable {
        var board: String = ""
        var clips: [String] = []
    }

    enum Action: Equatable {
        case clipTapped
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
}

struct ClipListView: View {
    let store: StoreOf<ClipListFeature>

    var body: some View {
        WithViewStore(store, observe: {$0}) {viewStore in
            List() {
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
    return ClipListView(
        store: Store(initialState: ClipListFeature.State(
            board: "Clips",
            clips: [
                "Test",
                "123",
                "456"
            ]
        )) {
            ClipListFeature()
                ._printChanges()
        }
    )
    .modelContainer(databaseService.container())
}
