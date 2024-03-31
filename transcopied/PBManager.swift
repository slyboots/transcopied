//
//  PBManager.swift
//  Transcopied
//
//  Created by Dakota Lorance on 12/6/23.
//

import Combine
import Foundation
import LinkPresentation
import SwiftUI
import SwiftUIX
import UniformTypeIdentifiers

public enum PasteType: String, CaseIterable {
    case image = "public.image"
    case url = "public.url"
    case text = "public.plain-text"
    case file = "public.content"
    static subscript(index: String) -> PasteType? {
        PasteType(rawValue: index) ?? PasteType.allCases.first(where: { index == "\($0)" })!
    }
}

@Observable
class PBManager {
//    var incomingBuffer: Any?
//    var changes: Int = 0
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
            if board.string!.isURL() {
                return "public.url"
            }
            return "public.plain-text"
        }
        if board.value(forPasteboardType: "public.content") != nil {
            return "public.content"
        }
        return nil
    }

    func hashed(data: Any, type: PasteType) -> Int {
        switch type {
            case .image:
                ((data as? Data)?.base64EncodedString().hashValue)!
            case .url:
                ((data as? URL)?.absoluteString.hashValue)!
            case .text:
                (data as? String)!.hashValue
            default:
                (data as? Data)!.hashValue
        }
    }

    func get() -> Any? {
        if !canCopy {
            return nil
        }

//        changes = board.changeCount
        if let url = board.url {
            return url
        }
        if let image = board.image {
            return image
        }
        if let string = board.string {
            if string.isURL() {
                return URL(string: string)
            }
            return string
        }
        return board.value(forPasteboardType: "public.content")
    }

    func set(_ data: Any, type: String) {
        switch type {
            case PasteboardContentType.text.rawValue:
                board.setValue(data, forPasteboardType: type)
            case PasteboardContentType.url.rawValue:
                board.setValue(data, forPasteboardType: type)
            case PasteboardContentType.image.rawValue:
                board.setValue(data, forPasteboardType: type)
            case PasteboardContentType.file.rawValue:
                board.setValue(data, forPasteboardType: type)
            default:
                board.setValue(data, forPasteboardType: UIPasteboard.typeAutomatic)
        }
    }

    func set(_ data: CopiedItem) {
        switch data.type {
            case PasteboardContentType.text.rawValue:
                board.setValue(data.content, forPasteboardType: data.type)
            case PasteboardContentType.url.rawValue:
                board.setValue(data.content, forPasteboardType: data.type)
            case PasteboardContentType.image.rawValue:
                board.setValue(data.data, forPasteboardType: data.type)
            case PasteboardContentType.file.rawValue:
                board.setValue(data.data, forPasteboardType: data.type)
            default:
                board.setValue(data.content.isEmpty ? data.data : data.content, forPasteboardType: UIPasteboard.typeAutomatic)
        }
    }
}

public extension String {
    func isURL() -> Bool {
        guard let url = URL(string: self) else {
            return false
        }
        return !(url.scheme == nil || url.host() == nil)
    }
}

struct TView: UIViewRepresentable {
    func updateUIView(_ uiView: LPLinkView, context: Context) {}

    func makeUIView(context: Context) -> LPLinkView {
        let uiView = LPLinkView(url: URL(string: "https://www.google.com/")!)

        return uiView
    }
}

#Preview {
    Group {
        ActivityIndicator()
            .animated(true)
            .style(.large)
        VStack {
            Text("https://www.google.com/")
                .frame(width: .infinity, alignment: .leading)
            LinkPresentationView(url: URL(string: "https://www.facebook.com/")!)
                .frame(width: 100, alignment: .leading)
        }
        .frame(height: 200)
    }
}

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
    func onPasteboardContent(perform action: @escaping () -> Void) -> some View {
        modifier(ClipboardHasContentModifier(action: action))
    }

    func pasteboardContext() -> some View {
        modifier(PasteboardContextModifier())
    }
}

//extension UIPasteboard {
//    var hasContent: Bool {
//        numberOfItems > 0 && contains(pasteboardTypes: PasteType.allCases.map(\.rawValue))
//    }
//
////    var hasContentPublisher: AnyPublisher<Bool, Never> {
////        Just(hasContent)
////            .merge(
////                with: NotificationCenter.default
////                    .publisher(for: UIPasteboard.changedNotification, object: self)
////                    .map { _ in self.hasContent }
////            )
//////            .merge(
//////                with: NotificationCenter.default
//////                    .publisher(for: UIApplication.didBecomeActiveNotification, object: nil)
//////                    .map { _ in self.hasContent })
////            .eraseToAnyPublisher()
////    }
//}
