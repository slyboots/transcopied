//
//  ClipListFeature.swift
//  Transcopied
//
    //  Created by Dakota Lorance on 3/31/24.
//

import Foundation
import ComposableArchitecture
import SwiftData
import SwiftUI


@Reducer
struct AppContainerFeature {
    @ObservableState
    struct State: Equatable {
//        var pbm: PBManager = PBManager()
        var modelContainer: ModelContext? = nil
        var navFocus: NavigationSplitViewColumn = .content
        var settingsShown: Bool = false
        var boards: [String] = []
        var clips: [String] = []
        var selectedBoard: String? = nil
        var selectedClip: CopiedItem? = nil
    }

    enum Action: Equatable {
        case sceneActivated
        case appeared
        case navShow(NavigationSplitViewColumn)
        case boardListRowTapped(String)
        case toggleSettingsTapped
        case none
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .sceneActivated:
//                    Toolbox.saveClipboard(pbm: state.pbm, modelContext: state.modelContainer!)
                    return .none
                case .appeared:
//                    Toolbox.saveClipboard(pbm: state.pbm, modelContext: state.modelContainer!)
                    return .none
                case .navShow(let focused):
                    state.navFocus = focused
                    return .none
                case .toggleSettingsTapped:
                    state.settingsShown = !state.settingsShown
                    return .none
                case .boardListRowTapped(let board):
                    state.navFocus = .content
                    state.selectedBoard = board
                    return .none
                case .none:
                    return .none
            }
        }
    }
}

// Just a container for the 3 column
// navigation split view used by the app
struct AppContainerView: View {
    let store: StoreOf<AppContainerFeature>

    var body: some View {
        WithViewStore(store, observe:{ $0 }) { viewStore in
            NavigationSplitView(preferredCompactColumn: viewStore.binding(get: \.navFocus, send: { .navShow($0) })) {
                List() {
                    ForEach(enumerating: viewStore.state.boards) { board in
                        LabeledContent {
                            Text(">")
                        } label: {
                            Label(board, systemImage: "clipboard")
                        }
                        .onTapGesture {
                            viewStore.send(.boardListRowTapped(board))
                        }
                    }
                }
                .listStyle(.inset)
            } content: {
                VStack {
                    Text("Content")
                    List {
                        ForEach(enumerating: store.state.clips) { clip in
                            Text(clip)
                        }
                    }
                }
            } detail: {
                VStack {
                    Text("Details")
                }
            }
        }
    }
}

#Preview("Vertical") {
    AppContainerView(
        store: Store(initialState: AppContainerFeature.State(boards:["Clips"], clips: ["Clip 1", "Test", "DATA"])) {
            AppContainerFeature()
        }
    )
}

#Preview("Horizontal", traits: .landscapeRight) {
    AppContainerView(
        store: Store(initialState: AppContainerFeature.State(boards:["Clips"], clips: ["Clip 1", "Test", "DATA"])) {
            AppContainerFeature()
        }
    )
}
