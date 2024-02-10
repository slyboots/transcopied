//
//  PBManager.swift
//  Transcopied
//
//  Created by Dakota Lorance on 12/6/23.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

typealias UIPB = UIPasteboard

private enum PasteType: String, CaseIterable {
    case text = "public.plain-text"
    case image = "public.image"
    case url = "public.url"
    case file = "public.file-url"
}

@Observable
final class PBoardManager {
    var buffer: Any?
    private var board: UIPasteboard = UIPasteboard.general

    private var _canCopy: Bool {
        if UIPB.general.numberOfItems < 1 {
            return false
        }
        else {
            return UIPB.general.contains(pasteboardTypes: [
                PasteType.text.rawValue,
                PasteType.image.rawValue,
                PasteType.url.rawValue,
                PasteType.file.rawValue,
            ])
        }
    }

    func get() -> [Any]? {
        if !_canCopy {
            return []
        }
        if self.board.hasImages {
            return self.board.images
        }
        else if self.board.hasURLs {
            return self.board.urls
        }
        else {
            return self.board.strings
        }
    }

    func set(data: [String: Any]) {
        UIPB.general.setItems([data])
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
