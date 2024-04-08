//
//  BoardListFeature.swift
//  Transcopied
//
//  Created by Dakota Lorance on 4/2/24.
//

import Foundation
import ComposableArchitecture
import SwiftUI


@Reducer
struct BoardListFeature {
    @ObservableState
    struct State: Equatable {
        var boards: [String] = []
        var selectedBoard: String? = nil
    }

    enum Action: Equatable {
        case boardTapped(String)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .boardTapped(let board):
                    state.selectedBoard = board
                    return .none
            }
        }
    }
}

struct BoardListView: View {
    let store: StoreOf<BoardListFeature>

    var body: some View {
        List() {
            Section {
                LabeledContent {Text("0").tint(.secondary)} label: {
                    Label("Copied", systemImage: "clipboard")
                }
                .listRowSeparator(.hidden)
                //                .onTapGesture {
                //                    viewStore.send(.boardListRowTapped(board))
                //                }
            }
            Section {
                ForEach(enumerating: ["Blah"]) { board in
                    LabeledContent {
                        Text("0")
                            .tint(.secondary)
                    } label: {
                        Label(board, systemImage: "line.3.horizontal.circle.fill")
                    }
                    .listRowSeparator(.hidden)
                }
                .listSectionSeparator(/*@START_MENU_TOKEN@*/.visible/*@END_MENU_TOKEN@*/)
            }
            Section {
                LabeledContent {EmptyView()} label: {
                    Label("Trash", systemImage: "trash").foregroundStyle(.red)
                }
                LabeledContent {EmptyView()} label: {
                    Label("Settings", systemImage: "slider.horizontal.3")
                }
                .listSectionSpacing(.compact)
                .listRowSeparator(.hidden)
            }
        }
        .listSectionSpacing(ListSectionSpacing.custom(20.0))
        .listStyle(.plain)
//        WithViewStore(store, observe: {$0}) {viewStore in
//            List() {
//                ForEach(enumerating: viewStore.state.boards) { board in
//                    LabeledContent {
//                        Text(">")
//                    } label: {
//                        Label(board, systemImage: "clipboard")
//                    }
//                    .onTapGesture {
//                        viewStore.send(.boardTapped(board))
//                    }
//                }
//            }
//            .listStyle(.inset)
//        }
    }
}

#Preview {
    @Dependency(\.databaseService) var databaseService
    return BoardListView(
        store: Store(
            initialState: BoardListFeature.State(
                boards: ["Clips"],
                selectedBoard: "Clips"
            )) {
            BoardListFeature()
        }
    )
    .modelContainer(databaseService.container())
}
