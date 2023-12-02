//
//  AppDetails.swift
//  Transcopied
//
//  Created by Dakota Lorance on 12/1/23.
//

import SwiftUI

struct AppDetails: View {
    @AppStorage("support") private var support: URL = URL(string: "mailto:apps@likethestates.com")!
    @AppStorage("project") private var project: URL = URL(string: "https://github.com/slyboots/transcopied")!

    var body: some View {
        ViewThatFits(in: .vertical) {
            List {
                Section(header: Text("About Transcopied"), content: {
                    HStack {
                        Link("Email Support", destination: support).foregroundStyle(.primary)
                    }.frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .center)

                    HStack {
                        Link("Source Code", destination: project)
                    }.frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .center).foregroundStyle(.primary)
                })
            }
            .padding()
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    AppDetails()
}
