//
//  CopiedItemList.swift
//  Transcopied
//
//  Created by Dakota Lorance on 11/26/23.
//
import SwiftData
import SwiftUI

struct ConditionalRowText: View {
    var main: String?
    var alt: String?
    var def: String = "Tap to edit"

    var body: some View {
        Text(calc(m: main, a: alt, d: def))
    }

    // swiftlint:disable identifier_name
    func calc(m: String?, a: String?, d: String) -> String {
        if m == nil, a == nil {
            return d
        }
        else if a != nil {
            return m != nil ? String(m!.prefix(100)) : String(a!.prefix(100))
        }
        else {
            // main should be safe to use
            return String(m!.prefix(100))
        }
    }
    // swiftlint:enable identifier_namecolumn    Int    1
}

struct CopiedItemRow: View {
    @Bindable var item: CopiedItem

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
                    ConditionalRowText(main: item.title, alt: item.content, def: "Empty Clipping! Tap to edit")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(8)
                }
                HStack {
                    Image(systemName: "info.circle")
                        .symbolRenderingMode(.monochrome)
                    Text("\(item.content?.count ?? 0) characters")
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

    private func relativeDateFmt(_ date: Date) -> String {
        let fmt = RelativeDateTimeFormatter()
        fmt.unitsStyle = .abbreviated
        return fmt.localizedString(fromTimeInterval: Date.now.distance(to: date))
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
                        CopiedEditorView(item: item, title: item.title)
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
            let newItem = CopiedItem(content: content, title: nil, timestamp: Date(), type: .text)
            modelContext.insert(newItem)
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
        let data = pasteboard.string
        return data
    }
}

#Preview {
    CopiedItemList()
        .modelContainer(for: CopiedItem.self, inMemory: true)
}
