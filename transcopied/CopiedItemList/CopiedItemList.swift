//
//  CopiedItemList.swift
//  Transcopied
//
//  Created by Dakota Lorance on 11/26/23.
//
import SwiftData
import SwiftUI


struct CopiedItemList: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(PBManager.self) private var pbm
    @Query private var items: [CopiedItem]

    var body: some View {
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
        .onAppear(perform: {self.addItem()})
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
        let emptySearch = searchText.isEmpty
        let anyScope = searchScope == ContentTypeFilter.any.rawValue
        let noFilter = emptySearch && anyScope
        let filter = #Predicate<CopiedItem> { item in
            return noFilter ||
                (anyScope || item.type.localizedStandardContains(searchScope)) &&
                (emptySearch || (
                    item.title.contains(searchText) ||
                    item.content.contains(searchText.utf8)
                ))
        }
        _items = Query(
            filter: filter,
            sort: \CopiedItem.timestamp,
            order: .reverse
        )
    }

    private func addItem() {
        withAnimation {
            let content = self.pbm.get()
            guard !(content == nil) else { return }

            let pbtype = self.pbm.uti
            
            let newItem = CopiedItem(
                content: content!,
                type: PasteboardContentType[pbtype!]!,
                title: "",
                timestamp: Date()
            )
            do {

                try newItem.save(context: modelContext)
            } catch _ {
                return
            }
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
enum ContentTypeFilter: String {
    case text = "public.text"
    case url = "public.url"
    case image = "public.image"
    case file = "public.content"
    case any = ""
    var id: String { return "\(self)" }
}

struct CopiedItemListContainer: View {
    @State private var searchText: String = ""
    @State private var searchTokens = [PasteboardContentType]()
    @State private var searchScope: ContentTypeFilter = .any

    var body: some View {
        CopiedItemList(searchText: searchText, searchScope: searchScope.rawValue)
            .searchable(text: $searchText)
            .searchScopes($searchScope, activation: .onSearchPresentation) {
                Text("Text").tag(ContentTypeFilter.text)
                Text("URL").tag(ContentTypeFilter.url)
                Text("Image").tag(ContentTypeFilter.image)
                Text("File").tag(ContentTypeFilter.file)
                Text("All").tag(ContentTypeFilter.any)
            }
    }
}

#Preview {
    NavigationStack {
        CopiedItemListContainer()
    }
    .pasteboardContext()
    .modelContainer(for: CopiedItem.self, inMemory: true)
}
