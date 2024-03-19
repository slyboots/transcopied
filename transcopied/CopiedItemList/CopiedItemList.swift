//
//  CopiedItemList.swift
//  Transcopied
//
//  Created by Dakota Lorance on 11/26/23.
//
import SwiftData
import SwiftUI
import CompoundPredicate


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

    static func contentAsStringMatch(content: Data) ->  Predicate<CopiedItem> {
//        let dataContent = Data(content.utf8)
        let strContent = String(data: content, encoding: .utf8)!
        
        return #Predicate<CopiedItem> {
            content.isEmpty || (
                $0.content.contains(strContent) ||
                $0.title.contains(strContent)
            )
        }
    }
    
    init(searchText: String, searchScope: String) {
        let searchData = searchText.data(using: .utf8) ?? nil

        let emptyScope = #Predicate<CopiedItem> {item in
            return searchScope.isEmpty
        }
        let matchesScope = #Predicate<CopiedItem>{item in
            item.type.localizedStandardContains(searchScope)
        }
        let emptySearch = #Predicate<CopiedItem>{item in
            searchText.isEmpty
        }
        let matchingTitle = #Predicate<CopiedItem>{item in
            item.title.contains(searchText)
        }
//        let matchingContent = #Predicate<CopiedItem>{item in
//            searchData != nil ? item.content.contains(searchData!) : false
//        }
        let matchingContent = CopiedItemList.contentAsStringMatch(content: searchData!)

        let scopeFilter = [emptyScope, matchesScope].disjunction()
        let queryFilter = [emptySearch, [matchingTitle, matchingContent].disjunction()].disjunction()

//        let queryFilter = [matchingContent, matchingTitle].disjunction()
        
        _items = Query(
//            filter: [queryFilter, scopeFilter].conjunction(),
            filter: queryFilter,
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
    case text = "public.plain-text"
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
//            .searchScopes($searchScope, activation: .onSearchPresentation) {
//                Text("Text").tag(ContentTypeFilter.text)
//                Text("URL").tag(ContentTypeFilter.url)
//                Text("Image").tag(ContentTypeFilter.image)
//                Text("File").tag(ContentTypeFilter.file)
//                Text("All").tag(ContentTypeFilter.any)
//            }
    }
}

#Preview {
    NavigationStack {
        CopiedItemListContainer()
    }
    .pasteboardContext()
    .modelContainer(for: CopiedItem.self, inMemory: true)
}
