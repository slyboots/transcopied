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
}

@Observable
class PBoardManager {
    var currentBoard: Any?
    var currentUTI: PasteType?
    var changes: Int = 0
    private var board: UIPasteboard = UIPasteboard.general

    var canCopy: Bool {
        return board.numberOfItems > 0 && board.changeCount > changes && board.contains(
            pasteboardTypes: PasteType.allCases.map(\.rawValue)
        )
    }

    func uti() -> PasteType? {
        if board.numberOfItems == 0 {
            return nil
        }
        if board.hasImages {
            return PasteType.image
        }
        else if board.hasURLs {
            return PasteType.url
        }
        else if board.hasStrings {
            return PasteType.text
        }
        else {
            return PasteType.file
        }
    }

    func pt2ct(pt: PasteType) -> PasteboardContentType? {
        if pt == PasteType.image {
            return PasteboardContentType.image
        }
        else if (pt == PasteType.url) {
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

        var PT = PasteType.file.rawValue
        var PV: Any?

        if board.hasImages {
            PT = PasteType.image.rawValue
            PV = board.images?.first!.pngData()
        }
        else if board.hasURLs {
            PT = PasteType.url.rawValue
            PV = board.urls?.first!
        }
        else if board.hasStrings {
            PT = PasteType.text.rawValue
            PV = board.string
        }
        else {
            PT = PasteType.file.rawValue
            PV = board.value(forPasteboardType: PT)
        }

//        if PV != nil {
//            buffer = PV ?? nil
//        }

        return PV
    }

    func set(data: [String: Any]) {
        board.setItems([data])
    }
}

private struct PasteboardContextModifier: ViewModifier {
    func body(content: Content) -> some View {
        @State var pbm = PBoardManager()
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
            .onReceive(NotificationCenter.default.publisher(for:  UIPasteboard.changedNotification)) { _ in
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
        self.numberOfItems > 0 && self.contains(pasteboardTypes: PasteType.allCases.map(\.rawValue))
    }
    var hasContentPublisher: AnyPublisher<Bool, Never> {
        return Just(hasContent)
            .merge(
                with: NotificationCenter.default
                    .publisher(for: UIPasteboard.changedNotification, object: self)
                    .map { _ in self.hasContent })
//            .merge(
//                with: NotificationCenter.default
//                    .publisher(for: UIApplication.didBecomeActiveNotification, object: nil)
//                    .map { _ in self.hasContent })
            .eraseToAnyPublisher()
    }
}
