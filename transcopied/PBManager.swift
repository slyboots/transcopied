//
//  PBManager.swift
//  Transcopied
//
//  Created by Dakota Lorance on 12/6/23.
//

import Foundation
import SwiftUI


final class PBManager {
    static func getClipboard() -> String? {
        let pasteboard = UIPasteboard.general
        let data = pasteboard.string
        return data
    }
}
