//
//  CopiedEditorView.swift
//  Transcopied
//
//  Created by Dakota Lorance on 11/28/23.
//
import Foundation
import SwiftData
import SwiftUI
import SwiftUIX
import UniformTypeIdentifiers

struct CopiedEditorView: View {
    enum EditorFocused {
        case title
        case content
    }

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.modelContext) private var modelContext
    @Environment(PBManager.self) private var pbm
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
                            .maxHeight(75)
                        TextEditor(text: $item.content)
                            .foregroundStyle(.primary)
                            .focused($editorFocused, equals: .content)
                            .onChange(of: editorFocused) {
                                bottomBarPlacement = editorFocused != nil ? .keyboard : .bottomBar
                            }
                    }
                case "public.image":
                    VStack {
                        Image(data: item.data)!
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
        .defaultFocus($editorFocused, EditorFocused.title)
        .onAppear(perform: {
            let _t = (item.title)
            let _c = (item.text)

            if !_c.isEmpty {
                editorFocused = .content
            }
            else if !_t.isEmpty, _c.isEmpty {
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
                    Label("Copy", systemImage: "square.and.arrow.up.on.square")
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
        let binaryTypes = [PasteboardContentType.image.rawValue, PasteboardContentType.file.rawValue]
        if binaryTypes.contains([item.type]) {
            pbm.set(item.data, type: item.type)
        }
        else {
            pbm.set(item.content, type: item.type)
        }
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
    .pasteboardContext()
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
    .pasteboardContext()
    .modelContainer(for: CopiedItem.self, inMemory: true)
}

#Preview("URL Clip no Title") {
    CopiedEditorView(
        item: CopiedItem(
            content: URL(string: "https://www.reddit.com/") as Any,
            type: PasteboardContentType.url,
            title: "",
            timestamp: Date()
        )
    )
    .pasteboardContext()
    .modelContainer(for: CopiedItem.self, inMemory: true)
}

#Preview("Image Clip with Title") {
    CopiedEditorView(
        item: CopiedItem(
            content: UIImage(systemName: "info.circle")!,
            type: PasteboardContentType.image,
            title: "Title",
            timestamp: Date()
        )
    )
    .pasteboardContext()
    .modelContainer(for: CopiedItem.self, inMemory: true)
}

#Preview("Image Clip no Title") {
    CopiedEditorView(
        item: CopiedItem(
            content: UIImage(systemName: "clock")!,
            type: PasteboardContentType.image,
            title: "",
            timestamp: Date()
        )
    )
    .pasteboardContext()
    .modelContainer(for: CopiedItem.self, inMemory: true)
}
