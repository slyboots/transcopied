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

    var body: some View {
        ViewThatFits(in: .vertical) {
            List {
                Section(header: Text("About Transcopied").foregroundStyle(.accent).font(.subheadline), content: {

                    Group {
                        Link("Email Support", destination: support)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity/*@END_MENU_TOKEN@*/, alignment: .center)
                    .foregroundStyle(.primary)
                    }

                    Link("Source Code", destination: project)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity/*@END_MENU_TOKEN@*/, alignment: .center)
                    .foregroundStyle(.primary)
                }
                )
            }
            .padding()
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    AppDetails()
}
