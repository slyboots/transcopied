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

extension CopiedItem {
    enum Errors: Error {
        case alreadyExists
    }
}

extension CopiedItem {
    /// exists function to check if title already exist or not
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
        if !exists(context: context, uid: uid) {
            context.insert(self)
        }
        else {
            throw CopiedItem.Errors.alreadyExists
        }
    }
}

extension CopiedItem {
    @Transient
    var text: String {
        get { content }
        set {
            content = newValue
        }
    }

    @Transient
    var url: URL {
        get { URL(string: content)! }
//        get { return type == PasteboardContentType.url.rawValue ? URL(string: String(data: content, encoding: .utf8)!) : nil }
        set {
            content = newValue.absoluteString.removingPercentEncoding!
        }
    }

    @Transient
    var file: Data? {
        get { type == PasteboardContentType.file.rawValue ? data : nil }
        set { data = Data(newValue!) }
    }

    @Transient
    var image: UIImage? {
        get { type == PasteboardContentType.image.rawValue ? UIImage(data: data) : nil }
        set {
            data = Data(newValue!.pngData()!)
        }
    }
}

enum PasteboardContentType: String, Codable, Identifiable, CaseIterable, Hashable {
    case text = "public.plain-text"
    case url = "public.url"
    case image = "public.image"
    case file = "public.content"
    var id: String { "\(self)" }

    static subscript(index: String) -> PasteboardContentType? {
        PasteboardContentType(rawValue: index) ?? PasteboardContentType.allCases
            .first(where: { index == "\($0)" })!
    }
}

func hashString(data: Data) -> String {
    SHA256.hash(data: data).compactMap { String(format: "%02x", $0) }.joined()
}

#Preview {
    Group {
        Text("Test")
    }
}
