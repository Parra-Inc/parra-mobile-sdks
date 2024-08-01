//
//  ContentView.swift
//  ParraDev
//
//  Created by Mick MacCallum on 7/31/24.
//

import SwiftUI
import Parra

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")

            PoweredByParraButton()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
