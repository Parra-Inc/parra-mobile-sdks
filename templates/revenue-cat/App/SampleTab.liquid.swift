//
//  SampleTab.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import Parra
import SwiftUI

struct SampleTab: View {
    @Environment(\.parraTheme) private var parraTheme
    @State private var isDisplayingUpsell = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "app.dashed")
                    .resizable()
                    .foregroundStyle(.gray)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 96)

                Text("We can't wait to see\nwhat you build!")
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)

                Button("Upsell with RevenueCat 😻") {
                    isDisplayingUpsell = true
                }

                Link(
                    destination: URL(
                        string: "https://docs.parra.io/templates/{{ template.name }}/swiftui"
                    )!
                ) {
                    Text("Get started")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("App")
            .background(parraTheme.palette.secondaryBackground)
        }
        .sheet(isPresented: $isDisplayingUpsell) {
            ProUpsellModal()
        }
    }
}

#Preview {
    ParraAppPreview {
        SampleTab()
    }
}
