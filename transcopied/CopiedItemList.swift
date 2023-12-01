//
//  CopiedItemList.swift
//  Transcopied
//
//  Created by Dakota Lorance on 11/26/23.
//
import SwiftData
import SwiftUI

struct CopiedItemRow: View {
    var item: CopiedItem
    private func relativeDateFmt(_ date: Date) -> String {
        let fmt = RelativeDateTimeFormatter()
        fmt.unitsStyle = .abbreviated
        return fmt.localizedString(fromTimeInterval: Date.now.distance(to: date))
    }

    var body: some View {
        HStack(alignment: .top) {
            VStack {
                Image(systemName: "text.alignleft")
                    .imageScale(.large)
                    .symbolRenderingMode(.monochrome)
                    .foregroundColor(.secondary)
            }
            .frame(maxHeight: .infinity, alignment: .center)
            VStack {
                HStack {
                    let rowtext = item.title == "Untitled" ? String(item.content.prefix(100)) : item.title
                    Text(rowtext)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(8)
                }
                HStack {
                    Image(systemName: "info.circle")
                        .symbolRenderingMode(.monochrome)
                    Text("\(item.content.count) characters")
                    Image(systemName: "clock")
                        .symbolRenderingMode(.monochrome)
                    Text(relativeDateFmt(item.timestamp))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            VStack {}
        }
        .padding(.leading)
        .frame(maxHeight: .infinity, alignment: .center)
    }
}

struct CopiedItemList: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [CopiedItem]

    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        CopiedEditorView(item: item)
                    } label: {
                        CopiedItemRow(item: item)
                    }
                    .foregroundStyle(.primary)
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Clippings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton().padding(.trailing)
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("New", systemImage: "square.and.arrow.down", action: addItem)
                    Spacer()
//                        Text("Clippings").font(.caption)
                    Spacer()
                    Image(systemName: "slider.horizontal.3").imageScale(.medium)
                        .foregroundStyle(.primary)
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let content = getClipboard()
            if content != nil {
                let newItem = CopiedItem(content: content!, timestamp: Date(), type: .text)
                modelContext.insert(newItem)
            } else {}
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }

    private func getClipboard() -> String? {
        let pasteboard = UIPasteboard.general
        if let data = pasteboard.string {
            return data
        }
//        return randomAlphanumericString(6)
        return nil
    }

    private func randomAlphanumericString(_ length: Int) -> String {
        let aln = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return (0 ..< length).map { _ in
            String(aln.randomElement()!)
        }.reduce("", +)
    }

    private func relativeDateFmt(_ date: Date) -> String {
        let fmt = RelativeDateTimeFormatter()
        fmt.unitsStyle = .abbreviated
        return fmt.localizedString(fromTimeInterval: Date.now.distance(to: date))
    }
}

#Preview {
    CopiedItemList()
        .modelContainer(for: CopiedItem.self, inMemory: true)
}
