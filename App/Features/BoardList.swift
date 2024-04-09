//
//  BoardListFeature.swift
//  Transcopied
//
//  Created by Dakota Lorance on 4/2/24.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct BoardList {
    @ObservableState
    struct State: Equatable {
        var boards: [String] = []
        var selectedBoard: String? = nil
    }

    enum Action: Equatable {
        case addButtonTapped
        case boardTapped(String)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .addButtonTapped:
                    return .none
                case let .boardTapped(board):
                    state.selectedBoard = board
                    return .none
            }
        }
    }
}

struct BoardListView: View {
    let store: StoreOf<BoardList>

    var body: some View {
        List {
            Section {
                LabeledContent { Text("0").tint(.secondary) } label: {
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
                .listSectionSeparator(/*@START_MENU_TOKEN@*/ .visible/*@END_MENU_TOKEN@*/)
            }
            Section {
                LabeledContent { EmptyView() } label: {
                    Label("Trash", systemImage: "trash").foregroundStyle(.red)
                }
                LabeledContent { EmptyView() } label: {
                    Label("Settings", systemImage: "slider.horizontal.3")
                }
                .listSectionSpacing(.compact)
                .listRowSeparator(.hidden)
            }
        }
        .listSectionSpacing(ListSectionSpacing.custom(20.0))
        .listStyle(.plain)
        .navigationTitle("Boards")
        .navigationBarTitleDisplayMode(.inline)
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
    return NavigationSplitView(
        preferredCompactColumn: .constant(.sidebar),
        sidebar: {
            BoardListView(
                store: Store(
                    initialState: BoardList.State(
                        boards: ["Clips"],
                        selectedBoard: "Clips"
                    )
                ) {
                    BoardList()
                }
            )
        },
        detail: { EmptyView() }
    )

    .modelContainer(databaseService.container())
}
