//
//  Toolbox.swift
//  Transcopied
//
//  Created by Dakota Lorance on 3/30/24.
//

import Foundation
import SwiftData


class Toolbox {
    public static func saveClipboard(pbm: PBManager, modelContext: ModelContext) {
        if pbm.canCopy {
                let content = pbm.get()
                guard !(content == nil) else {
                    return
                }
                
                let pbtype = pbm.uti
                
                let newItem = CopiedItem(
                    content: content!,
                    type: PasteboardContentType[pbtype!]!,
                    title: "",
                    timestamp: Date()
                )
                do {
                    try newItem.save(context: modelContext)
                } catch _ {
                    return
                }
            }
    }
}
