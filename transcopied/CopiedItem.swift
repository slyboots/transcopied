//
//  CopiedItem.swift
//  Transcopied
//
//  Created by Dakota Lorance on 11/26/23.
//

import Foundation
import SwiftData

enum CopiedItemType: String, Codable {
    case Text = "TXT"
    case URL = "URL"
    case File = "FILE"
}

@Model
final class CopiedItem {
    var title: String = "Untitled"
    var content: String = ""
    var timestamp: Date = Date.init(timeIntervalSinceNow: TimeInterval(0))
    var type: CopiedItemType = CopiedItemType.Text

    init(content: String, title: String? = nil, timestamp: Date, type: CopiedItemType) {
        self.content = content
        self.timestamp = timestamp
        self.type = type
        if title == nil {
            self.title = "Untitled"
        }
        else {
            self.title = title!
        }
    }
}
