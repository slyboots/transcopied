//
//  CopiedEditorView.swift
//  Transcopied
//
//  Created by Dakota Lorance on 11/28/23.
//
import Foundation
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct CopiedEditorView: View {
    enum EditorFocused {
        case title, content
    }
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.modelContext) private var modelContext
    @Bindable var item: CopiedItem
    @State var title: String?

    @FocusState private var editorFocused: EditorFocused?
    @State private var bottomBarPlacement: ToolbarItemPlacement = .bottomBar
    @State private var copiedHapticTriggered: Bool = false

    var body: some View {
        VStack {
            TextField(text: $item.title, label: { EmptyView() })
                .font(.title2)
                .focused($editorFocused, equals: .title)
            Divider().padding(.vertical, 5).foregroundStyle(.primary)
            HStack {
                Text(item.type) +
                    Text(" - ") +
                    Text("\(item.content?.count ?? 0) characters")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.secondary)
            .font(.caption2)
            TextEditor(text: $item.content)
                .frame(
                    maxHeight: .infinity
                )
                .foregroundStyle(.primary)
                .focused($editorFocused, equals: .content)
                .onChange(of: editorFocused) {
                    bottomBarPlacement = editorFocused != nil ? .keyboard : .bottomBar
                }
        }
        .defaultFocus($editorFocused, EditorFocused.title)
        .onAppear(perform: {
            let _t = (item.title ?? "")
            let _c = (item.content ?? Data("".utf8))

            if (!_c.isEmpty) {
                editorFocused = .content
            }
            else if (!_t.isEmpty && _c.isEmpty) {
                editorFocused = .title
            }
            else {
                editorFocused = nil
            }

        })
        .accessibilityAction(.magicTap) { setClipboard() }
        .navigationTitle("Edit")
        .padding(.horizontal)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button(action: {
                    setClipboard()
                    copiedHapticTriggered.toggle()
                }, label: {
                    Label("Copy", systemImage: "square.and.arrow.down.on.square")
                        .sensoryFeedback(.success, trigger: copiedHapticTriggered)
                })
                Spacer()
                Spacer()
                Menu {
                    Button(role: .destructive, action: deleteItem, label: { Label("Delete", systemImage: "trash") })
                }
                label: {
                    Button(action: {}, label: { Label("More", systemImage: "ellipsis") })
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button(action: {
                    setClipboard()
                    copiedHapticTriggered.toggle()
                }, label: {
                    Label("Copy", systemImage: "square.and.arrow.down.on.square")
                        .sensoryFeedback(.success, trigger: copiedHapticTriggered)
                })
                Spacer()
                Spacer()
                Menu {
                    Button(role: .destructive, action: deleteItem, label: { Label("Delete", systemImage: "trash") })
                }
                label: {
                    Button(action: {}, label: { Label("More", systemImage: "ellipsis") })
                }
                .frame(minWidth: 44.0, maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private func deleteItem() {
        withAnimation {
            modelContext.delete(item)
            presentationMode.wrappedValue.dismiss()
        }
    }

    private func setClipboard() {
        if let _ = item.content {
            UIPasteboard.general.setValue(item.content!, forPasteboardType: UTType.plainText.identifier)
        }
    }
}

#Preview {
    CopiedEditorView(item: CopiedItem(content: "Testing 123", type: CopiedContentType.text, title: "", timestamp: Date()))
        .modelContainer(for: CopiedItem.self, inMemory: true)
}
