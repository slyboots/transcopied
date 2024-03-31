//
//  CopiedItemList.swift
//  Transcopied
//
//  Created by Dakota Lorance on 11/26/23.
//
import CompoundPredicate
import SwiftData
import SwiftUI

struct CopiedItemList: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(PBManager.self) private var pbm
    @Environment(\.editMode) private var editMode
    @Query private var items: [CopiedItem]
    @State private var selection = Set<PersistentIdentifier>()

    var body: some View {
        List(selection: $selection) {
            ForEach(items) { item in
                NavigationLink {
                    CopiedEditorView(item: item)
                } label: {
                    CopiedItemRow(item: item)
                }
                .foregroundStyle(.primary)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        deleteItem(item)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button() {
                        pbm.set(item)
                    } label: {
                        Label("Copy", systemImage: "arrow.up.doc.on.clipboard")
                            .tint(.green)
                    }
                }
            }
        }
        .onAppear(perform: {
            Toolbox.saveClipboard(pbm: pbm, modelContext: modelContext)
        })
        .navigationTitle("Clippings")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if editMode?.wrappedValue.isEditing == true {
                    Button(role: .destructive, action: deleteSelection) {
                        Label("Delete Clippings", systemImage: "trash")
                    }
                    .tint(Color.red)
                }
                EditButton().padding(.trailing)
            }
        }
        .animation(nil, value: editMode?.wrappedValue)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button("Paste", systemImage: "square.and.arrow.up", action: addItem)
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

    static func contentAsStringMatch(content: Data) -> Predicate<CopiedItem> {
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
        let emptyScope = #Predicate<CopiedItem> { _ in
            searchScope.isEmpty
        }
        let matchesScope = #Predicate<CopiedItem> { item in
            item.type.localizedStandardContains(searchScope)
        }
        let emptySearch = #Predicate<CopiedItem> { _ in
            searchText.isEmpty
        }
        let matchingTitle = #Predicate<CopiedItem> { item in
            item.title.localizedStandardContains(searchText)
        }
        let matchingContent = #Predicate<CopiedItem> { item in
            item.content.localizedStandardContains(searchText)
        }

        let scopeFilter = [emptyScope, matchesScope].disjunction()
        let queryFilter = [emptySearch, [matchingTitle, matchingContent].disjunction()].disjunction()

        _items = Query(
            filter: [queryFilter, scopeFilter].conjunction(),
            sort: \CopiedItem.timestamp,
            order: .reverse
        )
    }

    private func addItem() {
        withAnimation {
            let content = pbm.get()
            guard !(content == nil) else {
                return
            }

            let pbtype = pbm.uti

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
    private func deleteSelection() {
        withAnimation {
            for id in selection {
                do {
                    try modelContext.delete(model: CopiedItem.self, where: #Predicate<CopiedItem>{
                        $0.persistentModelID == id
                    })
                } catch {
                    print(selection)
                }
            }
        }
        self.editMode?.wrappedValue.toggle()
    }

    private func deleteItem(_ item: CopiedItem) {
        withAnimation {
            modelContext.delete(item)
        }
    }
}

enum ContentTypeFilter: String {
    case text = "public.plain-text"
    case url = "public.url"
    case image = "public.image"
    case file = "public.content"
    case any = ""
    var id: String { "\(self)" }
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
    Group {
        @State var exampleData: [CopiedItem] = [
            CopiedItem(
                content: "Test Just Text. Alot of text. Like a LOOOOOOOOOOOOOOOOOOOOOO00000000000000000000000000000T",
                type: .text,
                timestamp: nil
            ),
            CopiedItem(content: "Empty title falls back to content", type: .text, title: "TITLE", timestamp: nil),
            CopiedItem(
                content: "Test Text With Title And Timestamp",
                type: .text,
                title: "TITLE",
                timestamp: Date(timeIntervalSince1970: .zero)
            ),
            CopiedItem(
                content: "iuweghcdiouwgcoewudgsddddddddddddddddddddddddddddddddddddddsdddddddddddddddddddddddddddddddddddddddddddchoewudchoewudchoecwidhcduwhcouwdhcoudwhcowudhcoh",
                type: .text,
                title: "",
                timestamp: Date()
            ),
            CopiedItem(
                content: URL(string: "https://google.com")!,
                type: .url,
                timestamp: Date(timeIntervalSinceNow: -10000)
            ),
            CopiedItem(content: URL(string: "file:///tmp/test/owufhcowhcouwehdcouhedouchweoduhouhdcwdeo")!, type: .url, timestamp: nil),
            CopiedItem(
                content: URL(string: "https://areally.long.url/?q=123idhwiue")!,
                type: .url,
                title: "URL with a title",
                timestamp: Date(timeIntervalSince1970: .zero)
            ),
        ]
        NavigationStack {
            CopiedItemListContainer()
        }
        .pasteboardContext()
        .modelContainer(for: CopiedItem.self, inMemory: true, onSetup: { mc in
            do {
                let ctx = try mc.get()
                try exampleData.forEach { item in
                    try item.save(context: ctx.mainContext)
                }
            } catch {
                return
            }
        })
    }
}
