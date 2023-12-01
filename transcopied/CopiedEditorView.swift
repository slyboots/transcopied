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
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.modelContext) private var modelContext
    @Bindable var item: CopiedItem
    @FocusState private var editorFocused: Bool
    @State private var bottomBarPlacement: ToolbarItemPlacement = .bottomBar

    var body: some View {
        VStack {
            TextField(text: $item.title, label: {
                EmptyView()
            })
            .font(.title2)
            .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity/*@END_MENU_TOKEN@*/)
            Divider().padding(.vertical, 5).foregroundStyle(.primary)
            HStack {
                Text(item.type.rawValue) +
                    Text(" - ") +
                    Text("\(item.content.count) characters")
            }.frame(maxWidth: .infinity, alignment: .leading).foregroundStyle(.secondary).font(.caption2)
            TextEditor(text: $item.content)
                .frame(
                    maxWidth: /*@START_MENU_TOKEN@*/ .infinity/*@END_MENU_TOKEN@*/,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
                .padding(.top).foregroundStyle(.primary)
                .focused($editorFocused)
                .onChange(of: editorFocused) {
                    bottomBarPlacement = editorFocused ? .keyboard : .bottomBar
                }
        }
        .padding(.horizontal)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button(action: setClipboard) {
                    Label("Copy", systemImage: "square.and.arrow.down.on.square")
                }
                Spacer()
                Spacer()
                Menu {
                    Button(role: .destructive, action: deleteItem, label: { Label("Delete", systemImage: "trash") })
                }
                label: {
                    Button(role: .destructive, action: deleteItem, label: { Label("Delete", systemImage: "ellipsis") })
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button(action: setClipboard) {
                    Label("Copy", systemImage: "square.and.arrow.down.on.square")
                }
                Spacer()
                Spacer()
                Menu {
                    Button(role: .destructive, action: deleteItem, label: { Label("Delete", systemImage: "trash") })
                }
                label: {
                    Button(role: .destructive, action: deleteItem, label: { Label("More", systemImage: "ellipsis") })
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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

    private func randomAlphanumericString(_ length: Int) -> String {
        let aln = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return (0 ..< length).map { _ in
            String(aln.randomElement()!)
        }.reduce("", +)
    }

    private func relativeDateFmt(date: Date) -> String {
        let fmt = RelativeDateTimeFormatter()
        fmt.unitsStyle = .abbreviated
        return fmt.localizedString(fromTimeInterval: Date.now.distance(to: date))
    }
}

#Preview {
    CopiedEditorView(item: CopiedItem(content: "Testing 123", timestamp: Date(), type: CopiedItemType.text))
        .modelContainer(for: CopiedItem.self, inMemory: true)
}
