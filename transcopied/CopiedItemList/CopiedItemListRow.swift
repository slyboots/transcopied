//
//  CopiedItemListRow.swift
//  Transcopied
//
//  Created by Dakota Lorance on 3/3/24.
//

import SwiftUI

struct ConditionalRowText: View {
    var main: String?
    var alt: String? = ""
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
    private var iconName: String
    private var iconColor: Color

    var body: some View {
        HStack(alignment: .center) {
            VStack {
                HStack {
                    Image(systemName: self.iconName)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(self.iconColor)
                    Text(
                        !item.title.isEmpty
                        ? item.title
                        : (item.text)
                    )
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .underline(self.item.type.contains("url"))
//                    .foregroundStyle(.blue)
                }
                HStack {
                    // TODO: make this section differ based on item type
                    if !item.text.isEmpty {
                        Image(systemName: "info.circle")
                            .symbolRenderingMode(.monochrome)
                        Text("\(item.text.count) characters")
                    }
                    Image(systemName: "clock")
                        .symbolRenderingMode(.monochrome)
                    Text(relativeDateFmt(item.timestamp))
                }
                .dynamicTypeSize(.xSmall)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.footnote)
                .foregroundStyle(.tertiary)
            }
            .frame(maxHeight: 40)
        }
    }

    
    init(item: CopiedItem) {
        self.item = item
        switch item.type {
            case "public.image":
                self.iconName = "photo"
                self.iconColor = .accent
            case "public.url":
                self.iconName = "link"
                self.iconColor = .blue
            case "public.plain-text":
                self.iconName = "text.alignleft"
                self.iconColor = .secondary
            case "public.content":
                self.iconName = "curlybraces.square"
                self.iconColor = .secondary
            default:
                self.iconName = "questionmark"
                self.iconColor = .primary
        }
    }

    private func relativeDateFmt(_ date: Date) -> String {
        let fmt = RelativeDateTimeFormatter()
        fmt.unitsStyle = .abbreviated
        return fmt.localizedString(fromTimeInterval: Date.now.distance(to: date))
    }
}

#Preview("Text Row", traits: .sizeThatFitsLayout) {
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
        ]
        List(exampleData) { item in
            @Bindable var item = item

            CopiedItemRow(
                item: item
            )
        }
        .frame(height: 500, alignment: .center)
        .listStyle(.automatic)
        .modelContainer(for: CopiedItem.self, inMemory: true)
    }
}


#Preview("Url Row", traits: .sizeThatFitsLayout) {
    Group {
        @State var exampleData: [CopiedItem] = [
            CopiedItem(
                content: URL(string: "https://google.com")!.absoluteURL,
                type: .url,
                timestamp: Date.init(timeIntervalSinceNow: -10000)
            ),
            CopiedItem(content: URL(string: "file:///tmp/test/owufhcowhcouwehdcouhedouchweoduhouhdcwdeo")!.absoluteURL, type: .url, timestamp: nil),
            CopiedItem(
                content: URL(string: "https://areally.long.url/?q=123idhwiue")!,
                type: .url,
                title: "URL with a title",
                timestamp: Date(timeIntervalSince1970: .zero)
            ),
        ]
        List(exampleData) { item in
            @Bindable var item = item
            
            CopiedItemRow(
                item: item
            )
        }
        .frame(height: 500, alignment: .center)
        .listStyle(.automatic)
        .modelContainer(for: CopiedItem.self, inMemory: true)
    }
}

#Preview("Url Preview Row", traits: .sizeThatFitsLayout) {
    Group {
        @State var exampleData: [CopiedItem] = [
            CopiedItem(
                content: URL(string: "https://google.com")!,
                type: .url,
                timestamp: Date.init(timeIntervalSinceNow: -10000)
            ),
            CopiedItem(content: URL(string: "file:///tmp/test/owufhcowhcouwehdcouhedouchweoduhouhdcwdeo")!, type: .url, timestamp: nil),
            CopiedItem(
                content: URL(string: "https://areally.long.url/?q=123idhwiue")!,
                type: .url,
                title: "URL with a title",
                timestamp: Date(timeIntervalSince1970: .zero)
            ),
        ]
        List(exampleData) { item in
            @Bindable var item = item
            
            CopiedItemRow(
                item: item
            )
        }
        .frame(height: 500, alignment: .center)
        .listStyle(.automatic)
        .modelContainer(for: CopiedItem.self, inMemory: true)
    }
}

