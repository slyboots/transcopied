//
//  Item.swift
//  nipper
//
//  Created by Dakota Lorance on 11/26/23.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
