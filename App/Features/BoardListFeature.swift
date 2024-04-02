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
        var boards: [String]
        var selectedBoard: String
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
        EmptyView()
    }
}

#Preview {
    BoardListView(
        store: Store(initialState: BoardListFeature.State(boards: ["Clips"], selectedBoard: "Clips")) {
            BoardListFeature()
        }
    )
}
