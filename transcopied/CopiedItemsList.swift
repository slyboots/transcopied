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
        Text(calc(main: main, alt: alt, fallback: def))
    }

    func calc(main: String?, alt: String?, fallback: String) -> String {
        if main == nil, alt == nil {
            return fallback
        }
        else if alt != nil {
            return main != nil ? String(main!.prefix(100)) : String(alt!.prefix(100))
        }
        else {
            // main should be safe to use
            return String(main!.prefix(100))
        }
    }
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

struct CopiedItemsList: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(PBoardManager.self) private var pbm
    @Query private var items: [CopiedItem]

    var body: some View {
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
//        .onAppear(perform: {self.addItem()})
        .navigationTitle("Clippings")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton().padding(.trailing)
            }
            ToolbarItem {
                Button(action: addItem) {
                    Label("Add Clipping", systemImage: "plus")
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button("Paste", systemImage: "square.and.arrow.down", action: addItem)
                    .accessibilityLabel("Add Clipping")
                Spacer()
                Spacer()
                NavigationLink {
                    AppDetails()
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .imageScale(.medium)
                        .foregroundStyle(.primary)
                }
            }
        }
    }

    init(searchText: String, searchScope: String) {
        let filter = #Predicate<CopiedItem> { item in
                return searchText.isEmpty ? 
                    (item.type.localizedStandardContains(searchScope) || searchScope == "") :
                    ((item.type.localizedStandardContains(searchScope) || searchScope == "") &&
                     ((item.title.localizedStandardContains(searchText) ?? false) ||
                      (String(data:item.content, encoding: UTF8)?.localizedStandardContains(searchText) ?? false))
                )
        }
        _items = Query(
            filter: filter,
            sort: \CopiedItem.timestamp,
            order: .reverse
        )
    }

    private func addItem() {
        withAnimation {
            let content = self.pbm.currentBoard
            if (content == nil) { return }

            let pbtype = pbm.currentUTI
            let uid = pbm.hashed(data: content!, type: pbtype!)

            let newItem = CopiedItem(
                content: content,
                type: pbm.pt2ct(pt: pbtype!)!,
                title: nil,
                timestamp: Date()
            )
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
}

struct CopiedItemsListContainer: View {
    @State private var searchText: String = ""
    @State private var searchTokens = [CopiedItemSearchToken.Kind]()
    @State private var searchScope: CopiedItemSearchToken.Kind = .any

    var body: some View {
        CopiedItemsList(searchText: searchText, searchScope: searchScope.rawValue)
            .searchable(text: $searchText)
            .searchScopes($searchScope, activation: .onSearchPresentation) {
                Text("Text").tag(CopiedItemSearchToken.Kind.text)
                Text("URL").tag(CopiedItemSearchToken.Kind.url)
                Text("Image").tag(CopiedItemSearchToken.Kind.image)
                Text("File").tag(CopiedItemSearchToken.Kind.file)
                Text("All").tag(CopiedItemSearchToken.Kind.any)
            }
    }
}

#Preview {
    NavigationStack {
        CopiedItemsListContainer()
    }
    .modelContainer(for: CopiedItem.self, inMemory: true)
}
