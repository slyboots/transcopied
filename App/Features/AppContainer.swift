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
struct AppContainer {
    @ObservableState
    struct State: Equatable {
        var sidebar = BoardList.State()
        var content = ClipList.State()

        var navFocus: NavigationSplitViewColumn = .content
        var settingsShown: Bool = false
        var boards: [String] = []
        var clips: [String] = []
        var selectedBoard: String? = nil
//        var selectedClip: CopiedItem? = nil
    }

    enum Action: Equatable {
        case sceneActivated
        case sidebar(BoardList.Action)
        case content(ClipList.Action)
        case appeared
        case navShow(NavigationSplitViewColumn)
        case boardListRowTapped(String)
        case toggleSettingsTapped
        case none
    }

    var body: some ReducerOf<AppContainer> {
        Scope<AppContainer.State, AppContainer.Action, BoardList>(state: \.sidebar, action: \.sidebar, child: {BoardList()})
        Scope<AppContainer.State, AppContainer.Action, ClipList>(state: \.content, action: \.content, child: {ClipList()})
        Reduce { state, action in
            return .none
//            switch action {
//                case .sceneActivated:
////                    Toolbox.saveClipboard(pbm: state.pbm, modelContext: state.modelContainer!)
//                    return .none
//                case .appeared:
////                    Toolbox.saveClipboard(pbm: state.pbm, modelContext: state.modelContainer!)
//                    return .none
//                case .navShow(let focused):
//                    state.navFocus = focused
//                    return .none
//                case .toggleSettingsTapped:
//                    state.settingsShown = !state.settingsShown
//                    return .none
//                case .boardListRowTapped(let board):
//                    state.navFocus = .content
//                    state.selectedBoard = board
//                    return .none
//                case .none:
//                    return .none
//            }
        }
    }
}

// Just a container for the 3 column
// navigation split view used by the app
struct AppContainerView: View {
    let store: StoreOf<AppContainer>

    var body: some View {
        WithViewStore(store, observe:{ $0 }) { viewStore in
            NavigationSplitView(preferredCompactColumn: viewStore.binding(get: \.navFocus, send: { .navShow($0) })) {
                BoardListView(store: store.scope(state: \.sidebar, action: \.sidebar))
            } content: {
                ClipListView(store: store.scope(state: \.content, action: \.content))
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
        store: Store(initialState: AppContainer.State(boards:["Clips"], clips: ["Clip 1", "Test", "DATA"])) {
            AppContainer()
        }
    )
}

#Preview("Horizontal", traits: .landscapeRight) {
    AppContainerView(
        store: Store(initialState: AppContainer.State(boards:["Clips"], clips: ["Clip 1", "Test", "DATA"])) {
            AppContainer()
        }
    )
}
