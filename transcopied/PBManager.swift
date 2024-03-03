//
//  PBManager.swift
//  Transcopied
//
//  Created by Dakota Lorance on 12/6/23.
//

import Combine
import Foundation
import SwiftUI
import UniformTypeIdentifiers

public enum PasteType: String, CaseIterable {
    case image = "public.image"
    case url = "public.url"
    case text = "public.plain-text"
    case file = "public.content"
    static subscript(index: String) -> PasteType? {
        get {
            return PasteType(rawValue: index) ?? PasteType.allCases.first(where: {"\($0)" == index })!
        }
    }
}

@Observable
class PBManager {
    var incomingBuffer: Any?
    var changes: Int = 0
    private var board: UIPasteboard = UIPasteboard.general

    var canCopy: Bool {
        let types = PasteType.allCases.map(\.rawValue)
        return board.contains(pasteboardTypes: types)
    }

    var uti: String? {
        if board.hasImages {
            return "public.image"
        }
        if board.hasURLs {
            return "public.url"
        }
        if board.hasStrings {
            return "public.plain-text"
        }
        if board.value(forPasteboardType: "public.content") != nil {
            return "public.content"
        }
        return nil
    }

    func pt2ct(pt: PasteType) -> PasteboardContentType? {
        if pt == PasteType.image {
            return PasteboardContentType.image
        }
        else if pt == PasteType.url {
            return PasteboardContentType.url
        }
        else if pt == PasteType.text {
            return PasteboardContentType.text
        }
        else {
            return PasteboardContentType.file
        }
    }

    func hashed(data: Any, type: PasteType) -> Int {
        switch type {
            case .image:
                return ((data as? Data)?.base64EncodedString().hashValue)!
            case .url:
                return ((data as? URL)?.absoluteString.hashValue)!
            case .text:
                return (data as? String)!.hashValue
            default:
                return (data as? Data)!.hashValue
        }
    }

    func get() -> Any? {
        if !canCopy {
            return nil
        }

        changes = board.changeCount
        if let url = board.url {
            return url
        }
        if let image = board.image {
            return image.pngData()
        }
        if let string = board.string {
            return string
        }
        return board.value(forPasteboardType: "public.content")
    }

    func set(data: [String: Any]) {
        board.setItems([data])
    }
}

// class PasteboardManager {
//    // Board references the system's general pasteboard
//    private var board: UIPasteboard = UIPasteboard.general
//
//    // Property to check if the board can copy data
//    var canCopy: Bool {
//        let types: [String] = ["public.image", "public.url", "public.plain-text", "public.content"]
//        guard !board.types.isEmpty else { return false }
//        for type in types {
//            if board.types.contains(type) { return true }
//        }
//        return false
//    }
//
//    // Function to get the UTI of the pasteboard contents
//    func uti() -> String? {
//        if board.hasImages { return "public.image" }
//        if board.hasURLs { return "public.url" }
//        if board.hasStrings { return "public.plain-text" }
//        if board.data(forPasteboardType: "public.content") != nil { return "public.content" }
//        return nil
//    }
//
//    // Function to retrieve data from the board
//    func get() -> Any? {
//        if let url = board.url { return url }
//        if let image = board.image { return image.pngData() }
//        if let string = board.string { return string }
//        return board.data(forPasteboardType: "public.content")
//    }
//
//    // Function to set data to the board
//    func set(data: [String: Any]) {
//        board.setItems([data], options: [:])
//    }
// }

private struct PasteboardContextModifier: ViewModifier {
    func body(content: Content) -> some View {
        @State var pbm = PBManager()
        Group {
            content
                .environment(pbm)
        }
    }
}

private struct SceneActivationActionModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIScene.didActivateNotification)) { _ in
                action()
            }
    }
}

private struct ClipboardHasContentModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIPasteboard.changedNotification)) { _ in
                action()
            }
    }
}

public extension View {
    func onSceneActivate(perform action: @escaping () -> Void) -> some View {
        modifier(SceneActivationActionModifier(action: action))
    }

    func onPasteboardContent(perform action: @escaping () -> Void) -> some View {
        modifier(ClipboardHasContentModifier(action: action))
    }

    func pasteboardContext() -> some View {
        modifier(PasteboardContextModifier())
    }
}

extension UIPasteboard {
    var hasContent: Bool {
        numberOfItems > 0 && contains(pasteboardTypes: PasteType.allCases.map(\.rawValue))
    }

    var hasContentPublisher: AnyPublisher<Bool, Never> {
        return Just(hasContent)
            .merge(
                with: NotificationCenter.default
                    .publisher(for: UIPasteboard.changedNotification, object: self)
                    .map { _ in self.hasContent }
            )
//            .merge(
//                with: NotificationCenter.default
//                    .publisher(for: UIApplication.didBecomeActiveNotification, object: nil)
//                    .map { _ in self.hasContent })
            .eraseToAnyPublisher()
    }
}
