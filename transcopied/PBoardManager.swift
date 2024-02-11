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

typealias UIPB = UIPasteboard

private enum PasteType: String, CaseIterable {
    case image = "public.image"
    case url = "public.url"
    case text = "public.plain-text"
    case file = "public.content"
}

@Observable
final class PBoardManager {
    var buffer: Any?
    var changes: Int = 0

    private var board: UIPasteboard = UIPasteboard.general

    private var _canCopy: Bool {
        return board.numberOfItems > 0 && board.contains(
            pasteboardTypes: PasteType.allCases.map(\.rawValue)
        )
    }

    func get() -> Any? {
        if !_canCopy {
            return nil
        }

        // nothing has been copied since last time
        if board.changeCount == changes {
            return buffer
        }
        else {
            changes = board.changeCount
        }

        var PT = PasteType.file.rawValue
        var PV: Any?

        if board.hasImages {
            PT = PasteType.image.rawValue
            PV = board.images?.first!
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

        if PV != nil {
            buffer = PV ?? nil
        }

        return buffer
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

public extension View {
    func onSceneActivate(perform action: @escaping () -> Void) -> some View {
        modifier(SceneActivationActionModifier(action: action))
    }

    func pasteboardContext() -> some View {
        modifier(PasteboardContextModifier())
    }
}
