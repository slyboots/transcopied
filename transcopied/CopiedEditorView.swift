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
import SwiftUIX

struct CopiedEditorView: View {
    enum EditorFocused {
        case title, content
    }
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.modelContext) private var modelContext
    @Bindable var item: CopiedItem

    @FocusState private var editorFocused: EditorFocused?
    @State private var bottomBarPlacement: ToolbarItemPlacement = .bottomBar
    @State private var copiedHapticTriggered: Bool = false

    var body: some View {
        VStack {
            TextField(text: $item.title, label: { EmptyView() })
                .font(.title2)
                .focused($editorFocused, equals: .title)
                .padding(.top)
            Divider().padding(.vertical, 5).foregroundStyle(.primary)

            switch item.type {
                case "public.plain-text":
                    HStack {
                        Text(item.type) +
                        Text(" - ") +
                        Text("\(item.text.count) characters")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.secondary)
                    .font(.caption2)
                    TextEditor(text: $item.text)
                        .frame(
                            maxHeight: .infinity
                        )
                        .foregroundStyle(.primary)
                        .focused($editorFocused, equals: .content)
                        .onChange(of: editorFocused) {
                            bottomBarPlacement = editorFocused != nil ? .keyboard : .bottomBar
                        }
                case "public.url":
                    VStack {
                        LinkPresentationView(url: item.url)
                            .maxHeight(50)
                        TextEditor(text: $item.url.stringBinding)
                            .padding()
                            .foregroundStyle(.primary)
                            .focused($editorFocused, equals: .content)
                            .onChange(of: editorFocused) {
                                bottomBarPlacement = editorFocused != nil ? .keyboard : .bottomBar
                            }
//                            .containerRelativeFrame(.horizontal, alignment: .top)
                        Spacer()
                    }

                default:
                    Spacer()
                    EmptyView()
            }
        }
        .defaultFocus($editorFocused, EditorFocused.title)
        .onAppear(perform: {
            let _t = (item.title )
            let _c = (item.text)

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
        UIPasteboard.general.setValue(item.content, forPasteboardType: UTType.plainText.identifier)
    }
}

#Preview("Text Clip") {
    CopiedEditorView(
        item: CopiedItem(
            content: "Text Content",
            type: PasteboardContentType.text,
            title: "Test Title",
            timestamp: Date()
        )
    )
    .modelContainer(for: CopiedItem.self, inMemory: true)
}

#Preview("URL Clip with Title") {
    CopiedEditorView(
        item: CopiedItem(
            content: URL(string: "https://www.reddit.com/")!,
            type: PasteboardContentType.url,
            title: "URL With Title",
            timestamp: Date()
        )
    )
    .modelContainer(for: CopiedItem.self, inMemory: true)
}

#Preview("URL Clip no Title") {
    CopiedEditorView(
        item: CopiedItem(
            content: URL(string: "https://www.reddit.com/"),
            type: PasteboardContentType.url,
            title: "",
            timestamp: Date()
        )
    )
    .modelContainer(for: CopiedItem.self, inMemory: true)
}


#Preview("Image Clip with Title") {
    CopiedEditorView(
        item: CopiedItem(
            content: "Testing 123",
            type: PasteboardContentType.text,
            title: "Preview Content",
            timestamp: Date()
        )
    )
    .modelContainer(for: CopiedItem.self, inMemory: true)
}

#Preview("Image Clip no Title") {
    CopiedEditorView(
        item: CopiedItem(
            content: "Testing 123",
            type: PasteboardContentType.text,
            title: "Preview Content",
            timestamp: Date()
        )
    )
    .modelContainer(for: CopiedItem.self, inMemory: true)
}
