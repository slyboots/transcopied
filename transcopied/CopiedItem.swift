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

extension CopiedContentType {
    static subscript(index: String) -> CopiedContentType {
        return CopiedContentType(rawValue: index)!
    }
}

enum CopiedContentType: String, Codable, Identifiable, CaseIterable, Hashable {
    case text
    case url
    case image
    case file
    case any
    var id: String { return "\(self)" }
}

class CopiedContentTypeTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }

    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        let enumValue = value as? CopiedContentType
        return enumValue?.rawValue
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let stringValue = value as? String else {
            return nil
        }
        return CopiedContentType(rawValue: stringValue)
    }
}
extension NSValueTransformerName {
    static let copiedContentTypeTransformerName = NSValueTransformerName(rawValue: "CopiedContentTypeTransformer")
}
//ValueTransformer.setValueTransformer(CopiedContentTypeTransformer(), forName: .copiedContentTypeTransformerName)

func clipboardHash(data: Data) -> String {
    return SHA256.hash(data: data).compactMap { String(format: "%02x", $0) }.joined()
}

struct CopiedItemSearchToken {
    typealias Kind = CopiedContentType
    var kind: CopiedContentType = .any
}

@Model
final class CopiedItem {
    @Attribute(.unique, originalName: "hash") var id: String
    var title: String
    var content: Data?
    @Attribute(.transformable(by: CopiedContentTypeTransformer)) var type: String = "\(CopiedContentType.text)"
    var timestamp: Date = Date(timeIntervalSinceNow: TimeInterval(0))

    init(content: Any?, type: CopiedContentType, title: String, timestamp: Date) {
        self.type = type.rawValue
        switch type {
            case .image:
                self.content = (content as! UIImage).pngData()!
            case .url:
                self.content = Data((content as! NSURL).absoluteString!.utf8)
            case .text:
                self.content = Data((content as! String).utf8)
            case .file:
                self.content = Data(content as! Data)
            default:
                self.content = Data(content as! Data)
        }
        self.timestamp = timestamp
        self.type = type.rawValue
        self.title = title
        self.id = clipboardHash(data: self.content ?? Data())
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
