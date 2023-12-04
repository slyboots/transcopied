//
//  AppDetails.swift
//  Transcopied
//
//  Created by Dakota Lorance on 12/1/23.
//

import SwiftUI

struct AppDetails: View {
    @AppStorage("support") private var support: URL = URL(string: "mailto:transcopied@dwl.dev")!
    @AppStorage("project") private var project: URL = URL(string: "https://github.com/slyboots/transcopied")!
    @AppStorage("privacy") private var privacy: URL = URL(string: "https://transcopied.dwl.dev/privacy")!

    var body: some View {
        List {
            Section(
                header: Text("About Transcopied")
                    .foregroundStyle(.accent)
                    .font(.subheadline),
                content: {
                    Link(destination: support) {
                        Text("Email Support")
                    }
                    Link(destination: project) {
                        Text("Source Code")
                    }
                    Link(destination: privacy) {
                        Text("Privacy Policy")
                    }
                })
        }
        .padding()
        .navigationTitle("Settings")
        .foregroundStyle(.primary)
    }
}

#Preview {
    AppDetails()
}
