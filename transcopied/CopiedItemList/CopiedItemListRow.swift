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

    var body: some View {
        HStack(alignment: .top) {
            VStack {
                switch item.type {
                    case "public.image":
                        Image(systemName: "text.alignleft")
                            .imageScale(.large)
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.accentColor)
                            .font(.system(size: 24))
                    case "public.url":
                        Image(systemName: "text.alignleft")
                            .imageScale(.large)
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.blue)
                            .font(.system(size: 24))
                    case "public.plain-text":
                        Image(systemName: "text.alignleft")
                            .imageScale(.large)
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.secondary)
                            .font(.system(size: 24))
                    default:
                        Image(systemName: "text.alignleft")
                            .imageScale(.large)
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.secondary)
                            .font(.system(size: 24))
                }
            }
            .frame(maxHeight: .infinity, alignment: .topTrailing)
            VStack {
                HStack {
                    Text(
                        !item.title.isEmpty
                            ? item.title
                            : (item.text ?? "")
                    )
                    .font(.callout)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                HStack {
                    Image(systemName: "info.circle")
                        .symbolRenderingMode(.monochrome)
                    Text("\(item.text?.count ?? 0) characters")
                    Image(systemName: "clock")
                        .symbolRenderingMode(.monochrome)
                    Text(relativeDateFmt(item.timestamp))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
        }
        .frame(maxHeight: 40, alignment: .center)
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
        .listStyle(.plain)
        .modelContainer(for: CopiedItem.self, inMemory: true)
    }
}
