//
//  CopiedItem.swift
//  Transcopied
//
//  Created by Dakota Lorance on 11/26/23.
//

import Foundation
import SwiftData
import SwiftUI

enum CopiedItemType: String, Codable {
    case text = "TXT"
    case url = "URL"
    case img = "IMG"
    case file = "FILE"
}

struct CopiedItemSearchToken {
    enum Kind: String, Identifiable, Hashable, CaseIterable {
        case txt = "TXT"
        case url = "URL"
        case img = "IMG"
        case file = "FILE"
        case all = ""
        var id: Self { self }
    }

    var kind: Kind = .all
}

@Model
final class CopiedItem {
    var title: String?
    var content: String?
    var image: Data?
    var timestamp: Date = Date(timeIntervalSinceNow: TimeInterval(0))
    var type: String = CopiedItemType.text.rawValue

    init(content: Any?, title: String?, timestamp: Date, type: CopiedItemType) {
        switch type {
            case .img:
                self.image = (content as! UIImage).pngData()
            case .file:
                // come back to this
                _ = {}
            default:
                self.content = (content as! String)
        }
        self.timestamp = timestamp
        self.type = type.rawValue
        self.title = title
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
