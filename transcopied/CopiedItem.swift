//
//  CopiedItem.swift
//  Transcopied
//
//  Created by Dakota Lorance on 11/26/23.
//

import CryptoKit
import Foundation
import SwiftData
import SwiftUI

enum PasteboardContentType: String, Codable, Identifiable, CaseIterable, Hashable {
    case text = "public.plain-text"
    case url = "public.url"
    case image = "public.image"
    case file = "public.content"
    var id: String { return "\(self)" }

    static subscript(index: String) -> PasteboardContentType? {
        return PasteboardContentType(rawValue: index) ?? PasteboardContentType.allCases
            .first(where: { index == "\($0)" })!
    }
}

enum CopiedContent {
    case string(String)
    case image(UIImage)
    case file(Data)
    case url(URL)
}

func hashString(data: Data) -> String {
    return SHA256.hash(data: data).compactMap { String(format: "%02x", $0) }.joined()
}

enum CopiedItemError: Error {
    case alreadyExists
}

@Model
final class CopiedItem {
    var uid: String = "00000000-0000-0000-0000-000000000000"
    var title: String = ""
    var type: String = ""
    var timestamp = Date(timeIntervalSince1970: .zero)
    var content: String = ""
    @Attribute(.externalStorage)
    var data = Data()

    @Transient
    var text: String {
        get { return content }
        set {
            content = newValue
        }
    }

    @Transient
    var url: URL {
        get { return URL(string: content)! }
//        get { return type == PasteboardContentType.url.rawValue ? URL(string: String(data: content, encoding: .utf8)!) : nil }
        set {
            content = newValue.absoluteString.removingPercentEncoding!
        }
    }

    @Transient
    var file: Data? {
        get { return type == PasteboardContentType.file.rawValue ? data : nil }
        set { data = Data(newValue!) }
    }

    @Transient
    var image: UIImage? {
        get { return type == PasteboardContentType.image.rawValue ? UIImage(data: data) : nil }
        set {
            data = Data(newValue!.pngData()!)
        }
    }

    init(content: Any, type: PasteboardContentType, title: String = "", timestamp: Date? = nil) {
        switch type {
            case .image:
                let I = (content as! UIImage)
                self.uid = hashString(data: I.pngData()!)
                self.type = PasteboardContentType.image.rawValue
                self.data = I.pngData()!
                self.title = title
            case .url:
                let U = (content as! URL)
                self.uid = hashString(data: Data(U.absoluteString.utf8))
                self.type = PasteboardContentType.url.rawValue
                self.content = U.absoluteString
                self.title = title.isEmpty ? (U.host() ?? U.formatted(.url)) : title
            case .text:
                let S = (content as! String)
                self.uid = hashString(data: Data(S.utf8))
                self.type = PasteboardContentType.text.rawValue
                self.content = S
                self.title = title
            case .file:
                let D = (content as! Data)
                self.uid = hashString(data: D)
                self.type = PasteboardContentType.file.rawValue
                self.data = Data(D)
                self.title = title
        }
        if !self.content.isEmpty || !data.isEmpty {
            self.timestamp = timestamp ?? Date(timeIntervalSinceNow: 0)
        }
    }

    // exists function to check if title already exist or not
    private func exists(context: ModelContext, uid: String) -> Bool {
        let predicate = #Predicate<CopiedItem> { $0.uid == uid }
        let descriptor = FetchDescriptor(predicate: predicate)

        do {
            let result = try context.fetch(descriptor)
            return !result.isEmpty ? true : false
        }
        catch {
            return false
        }
    }

    func save(context: ModelContext) throws {
        // find if the budget category with the same name already exists
        if !exists(context: context, uid: uid) {
            // save it
            context.insert(self)
        }
        else {
            // do something else
            throw CopiedItemError.alreadyExists
        }
    }
}

public extension Binding where Value == URL {
    var stringBinding: Binding<String> {
        .init(get: {
            self.wrappedValue.absoluteString.removingPercentEncoding!
        }, set: { newValue in
            self.wrappedValue = URL(string: newValue)!
        })
    }
}

public extension Binding {
    init(_ source: Binding<Value?>, _ defaultValue: Value) {
        self.init(get: {
            if source.wrappedValue == nil {
                source.wrappedValue = defaultValue
            }
            return source.wrappedValue ?? defaultValue
        }, set: {
            source.wrappedValue = $0
        })
    }

    init<T>(isNotNil source: Binding<T?>, defaultValue: T) where Value == Bool {
        self.init(
            get: { source.wrappedValue != nil },
            set: { source.wrappedValue = $0 ? defaultValue : nil }
        )
    }
}

public extension Binding where Value: Equatable {
    init(_ source: Binding<Value?>, nilAs nilValue: Value) {
        self.init(
            get: { source.wrappedValue ?? nilValue },
            set: { newValue in
                if newValue == nilValue {
                    source.wrappedValue = nil
                }
                else {
                    source.wrappedValue = newValue
                }
            }
        )
    }
}

#Preview {
    Group {
        Text("Test")
    }
}

// #Preview {
//    Group {
//        @Bindable var item: CopiedItem = CopiedItem(
//            content: "Test Content",
//            type: .text,
//            title: "Test Title",
//            timestamp: Date(timeIntervalSinceNow: 0)
//        )
//        VStack {
//            Text(item.title)
//            Text(item.type)
//            Text(item.content)
//            Text(item.timestamp.ISO8601Format())
//        }
//    }
//    .modelContainer(for: CopiedItem.self, inMemory: true, isAutosaveEnabled: true)
// }
