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
            TextField(text: Binding($item.title, nilAs: ""), label: { EmptyView() })
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
            TextEditor(text: Binding($item.content, nilAs: ""))
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
            let _c = (item.content ?? "")

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
        if item.content != nil {
            UIPasteboard.general.setValue(item.content as Any, forPasteboardType: UTType.plainText.identifier)
        }
    }
}

#Preview {
    CopiedEditorView(item: CopiedItem(content: "Testing 123", title: "", timestamp: Date(), type: CopiedItemType.text))
        .modelContainer(for: CopiedItem.self, inMemory: true)
}
