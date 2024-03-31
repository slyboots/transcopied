//
//  CopiedItemListRow.swift
//  Transcopied
//
//  Created by Dakota Lorance on 3/3/24.
//

import SwiftUI
import SwiftUIX

struct ConditionalRowText: View {
    var main: String?
    var alt: String? = ""
    var def: String = "Tap to edit"

    var body: some View {
        Text(calc(main: main, alt: alt, fallback: def))
    }

    func calc(main: String?, alt: String?, fallback: String) -> String {
        if main == nil, alt == nil {
            fallback
        }
        else if alt != nil {
            main != nil ? String(main!.prefix(100)) : String(alt!.prefix(100))
        }
        else {
            // main should be safe to use
            String(main!.prefix(100))
        }
    }
}

struct CopiedItemRow: View {
    @Bindable var item: CopiedItem
    private var iconName: String
    private var iconColor: Color

    private var bytefmt = ByteCountFormatter()

    var body: some View {
        HStack(alignment:.top, spacing: 0) {
            VStack(){
                Image(systemName: iconName)
                    .foregroundStyle(Color.accent)
                    .padding(.vertical, .extraSmall)
            }
            VStack(alignment: .leading) {
                if !item.title.isEmpty {
                    Text(item.title)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(0)
                        .contentMargins(0)
                }
                else {
                    if item.type == "public.content" {
                        Text("File Data")
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .padding(0)
                            .contentMargins(0)
                    }
                }
                if ["public.url", "public.plain-text"].contains([item.type]) {
                    Text(item.content)
                        .lineLimit(5)
                        .truncationMode(.tail)
                }
                if item.type == "public.image" {
                    Image(image: item.image!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxHeight:80)
                        .clipped()
                }
                if item.type == "public.content" {
                    Text("...")
                        .lineLimit(5)
                        .truncationMode(.tail)
                    
                }
                Spacer()
                HStack() {
                    if !item.text.isEmpty {
                        HStack(spacing:0) {
                            Image(systemName: "info.circle")
                                .symbolRenderingMode(.monochrome)
                            Text("\(item.text.count) characters")
                        }
                    }
                    if item.image != nil {
                        HStack {
                            Text("PNG "+item.image!.size.width.formatted()+"x"+item.image!.size.height.formatted())
                        }
                    }
                    if item.type == "public.content" {
                        HStack {
                            Text("DATA \(Double(item.file!.count) / (1024.0*1024.0))MB")
                        }
                    }
                    HStack(spacing:0) {
                        Image(systemName: "clock")
                            .symbolRenderingMode(.monochrome)
                        Text(relativeDateFmt(item.timestamp))
                    }
                }
                .font(.caption)
                .foregroundStyle(.tertiary)
            }
            if item.type == "public.url" {
                // TODO: Move this to be under the URL with the URL font size set smaller
                Spacer()
                VStack {
                    LinkPresentationView(url: item.url)
                        .squareFrame()
                        .maxWidth(50)
                        .maxHeight(50)
                        .allowsHitTesting(false)
                }
            }
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
            CopiedItem(
                content: "iuweghcdiouwgcoewudgsddddddddddddddddddddddddddddddddddddddsdddddddddddddddddddddddddddddddddddddddddddchoewudchoewudchoecwidhcduwhcouwdhcoudwhcowudhcoh",
                type: .text,
                title: "",
                timestamp: Date()
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

#Preview("Image Preview Row", traits: .sizeThatFitsLayout) {
    Group {
        @State var exampleData: [CopiedItem] = [
            CopiedItem(
                content: UIImage(systemName: "person.text.rectangle.fill")!,
                type: .image,
                title: "",
                timestamp: Date(timeIntervalSince1970: .zero)
            ),
            CopiedItem(
                content: UIImage(systemName: "clock")!,
                type: .image,
                title: "Image with a title",
                timestamp: Date(timeIntervalSince1970: .zero)
            ),
        ]
        List(exampleData) { item in
            @Bindable var item = item

            CopiedItemRow(
                item: item
            )
        }
        .frame(height: 500)
        .listStyle(.automatic)
        .modelContainer(for: CopiedItem.self, inMemory: true)
    }
}
