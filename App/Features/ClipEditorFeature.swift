//
//  ClipListFeature.swift
//  Transcopied
//
//  Created by Dakota Lorance on 3/31/24.
//

import ComposableArchitecture
import Foundation
import SwiftData
import SwiftUI
import SwiftUIX

enum EditorFocused {
    case title
    case content
}

@Reducer
struct ClipEditorFeature {
    @ObservableState
    struct State {
        var editorFocused: EditorFocused = .title
        var clip: CopiedItem?
    }

    enum Action {
        case contentFocused
        case copiedClip
        case deletedClip
        case titleFocused
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action as Action {
                case .contentFocused:
                    state.editorFocused = .content
                    return .none
                case .copiedClip:
                    PBManager().set(state.clip!)
                    return .none
                case .deletedClip:
                    state.clip!.modelContext?.delete(state.clip!)
                    state.clip = nil
                    return .none
                case .titleFocused:
                    state.editorFocused = .title
                    return .none
            }
        }
    }
}

struct ClipEditorView: View {
    let store: StoreOf<ClipEditorFeature>
    let item: String = ""

    var body: some View {
        VStack {
            TextField(text: .constant("Placeholder"), label: { EmptyView() })
                .font(.title2)
//                .focused(EditorFocused.title, equals: .title)
                .padding(.top)
            Divider().padding(.vertical, 5).foregroundStyle(.primary)

            switch item {
                case "public.plain-text":
                    HStack {
                        Text("item.type") +
                            Text(" - ") +
                            Text("(item.text.count) characters")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.secondary)
                    .font(.caption2)
                    TextEditor(text: .constant("$item.text"))
                        .frame(
                            maxHeight: .infinity
                        )
                        .foregroundStyle(.primary)
//                        .focused("$editorFocused", equals: .content)
//                        .onChange(of: editorFocused) {
//                            bottomBarPlacement = editorFocused != nil ? .keyboard : .bottomBar
//                        }
                case "public.url":
                    VStack {
                        LinkPresentationView(url: URL(string: "http://test.com/item.url")!)
                            .maxHeight(75)
                        TextEditor(text: .constant("$item.content"))
                            .foregroundStyle(.primary)
//                            .focused($editorFocused, equals: .content)
//                            .onChange(of: editorFocused) {
//                                bottomBarPlacement = editorFocused != nil ? .keyboard : .bottomBar
//                            }
                    }
                case "public.image":
                    VStack {
                        Image(data: Data("item.data".utf8))!
                            .resizable()
                            .scaledToFit()
                        Spacer()
                    }
                case "public.content":
                    VStack {
                        Text("Editing binary data is unsupported!")
                            .font(.headline)
                        Text("Add a title above to help you remember what this item contains")
                            .font(.subheadline)
                        Spacer()
                    }
                default:
                    Spacer()
                    EmptyView()
            }
        }
    }
}

#Preview {
    ClipEditorView(
        store: Store(initialState: ClipEditorFeature.State()) {
            ClipEditorFeature()
        }
    )
}
