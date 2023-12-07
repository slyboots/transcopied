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


enum CopiedItemKindScope: CaseIterable {
    case txt
    case url
    case img
    case file
    case all
}

struct CopiedItemSearchToken {
    enum Kind: String, Identifiable, Hashable, CaseIterable {
        case txt
        case url
        case img
        case file
        case all
        var id: Self {self}
    }

    enum Scope: String, Identifiable, Hashable, CaseIterable {
        case kind
        var id: Self {self}
    }
    var kind: Kind = .all
    var scope: Scope = .kind
}

//let copiedItemSearchTokens = [
//    CopiedItemTypeToken("txt"),
//    CopiedItemTypeToken("url"),
//    CopiedItemTypeToken("url"),
//    CopiedItemTypeToken("file"),
//]

@Model
final class CopiedItem {
    var title: String?
    var content: String?
    var timestamp: Date = Date(timeIntervalSinceNow: TimeInterval(0))
    var type: String = CopiedItemType.text.rawValue

    init(content: String?, title: String?, timestamp: Date, type: CopiedItemType) {
        self.content = content
        self.timestamp = timestamp
        self.type = type.rawValue
        self.title = title
    }


    static func predicate(searchText: String) -> Predicate<CopiedItem> {
        return #Predicate {
            if searchText.isEmpty {
                return true
            }
            else if $0.title?.localizedStandardContains(searchText) == true {
                return true
            }
            else if $0.content?.localizedStandardContains(searchText) == true {
                return true
            }
            else {
                return false
            }
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
        self.init(get: { source.wrappedValue != nil },
                  set: { source.wrappedValue = $0 ? defaultValue : nil })
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
            })
    }
}
