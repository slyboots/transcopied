//
//  ModalMessage.swift
//  Transcopied
//
//  Created by Dakota Lorance on 11/30/23.
//

import SwiftUI

@Observable
class ModalModel {
    var hasFocus: Bool = false
}

struct ModalMessageView: View {
    var label: String
    var message: String
    @FocusState var isFocused

    var body: some View {
        GroupBox(label: Text(label), content: {
            Text(message + " \(isFocused)")
                .focusable(true, interactions: [.activate, .edit, .automatic])
                .focused($isFocused)
        })
    }

    func focus(value: Bool) {}
}

struct ModalMessage: ViewModifier {
    @FocusState var appeared: Bool
    @State var trigger: Bool
    @State var dismiss: Bool = false

    func body(content: Content) -> some View {
        content.overlay(alignment: .bottomTrailing) {
            if dismiss, !trigger {
                EmptyView()
            }
            else {
                ModalMessageView(label: "Label", message: "Message")
                    .aspectRatio(2 / 5, contentMode: .fit)
                    .containerRelativeFrame([.vertical, .horizontal], alignment: .top)
                    .onChange(of: appeared) {
                        dismiss = appeared ? false : true
                    }
            }
        }
    }
}

#Preview {
    Group {
        @State var showToast: Bool = false
        Group {
            Text("Test")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .border(Color.black, width: 2.0)
                .onHover(perform: { hovering in
                    showToast = hovering
                })
                .modifier(ModalMessage(trigger: showToast))
        }
    }
}
