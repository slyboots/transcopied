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
    case text
    case url
    case image
    case file
    case any
    var id: String { return "\(self)" }
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
    var uid: String?
    var title: String = ""
    @Attribute(.externalStorage) var content: Data = Data()
    var text: String?
    @Transient var url: URL? {
        return self.type == PasteboardContentType.url.rawValue ? URL(string: String(data: self.content, encoding: .utf8)!) : nil
    }
    @Transient var file: Data? {
        return self.type == PasteboardContentType.file.rawValue ? self.content : nil
    }
    @Transient var image: UIImage? {
        return self.type == PasteboardContentType.image.rawValue ? UIImage(data: self.content) : nil
    }

    var type: String = PasteboardContentType.any.rawValue
    var timestamp: Date?

    init(content: CopiedContent, type: PasteboardContentType, title: String = "", timestamp: Date?) {
        switch content {
            case let .image(I):
                self.uid = hashString(data: I.pngData()!)
                self.type = PasteboardContentType.image.rawValue
                self.content = I.pngData()!
            case let .file(D):
                self.uid = hashString(data: D)
                self.type = PasteboardContentType.file.rawValue
                self.content = Data(D)
            case let .string(S):
                self.uid = hashString(data: Data(S.utf8))
                self.type = PasteboardContentType.text.rawValue
                self.content = Data(S.utf8)
            case let .url(U):
                self.uid = hashString(data: Data(U.absoluteString.utf8))
                self.type = PasteboardContentType.url.rawValue
                self.content = Data(U.absoluteString.utf8)
        }
        self.timestamp = timestamp ?? Date(timeIntervalSinceNow: TimeInterval(0))
        self.title = title
    }

    // exists function to check if title already exist or not
    private func exists(context: ModelContext, uid: String) -> Bool {

        let predicate = #Predicate<CopiedItem> { $0.uid == uid }
        let descriptor = FetchDescriptor(predicate: predicate)

        do {
            let result = try context.fetch(descriptor)
            return !result.isEmpty ? true: false
        } catch {
            return false
        }
    }

    func save(context: ModelContext) throws {

        // find if the budget category with the same name already exists
        if !exists(context: context, uid: self.uid!) {
            // save it
            context.insert(self)
        } else {
            // do something else
            throw CopiedItemError.alreadyExists
        }
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

//    init<T>(isNotNil source: Binding<T>, defaultValue: T) where Value == Data {
//        self.init
//    }
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
        @Bindable var item: CopiedItem = CopiedItem(content: .string("Test Content"), type: .text, title: "Test Title", timestamp: Date.init(timeIntervalSinceNow: 0))
        VStack {
            Text(item.title)
            Text(item.type)
            Text(String(data: item.content, encoding: .utf8)!)
            Text(item.timestamp!.ISO8601Format())
        }
    }
    .modelContainer(for: CopiedItem.self, inMemory: true, isAutosaveEnabled: true)
}
