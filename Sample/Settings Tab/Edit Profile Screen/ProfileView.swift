//
//  ProfileView.swift
//  Sample
//
//  Created by Mick MacCallum on 7/17/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Parra
import SwiftUI

struct ProfileView: View {
    var body: some View {
        List {
            Section("User info") {
                NavigationLink {} label: {
                    HStack {
                        Text("Name")

                        Spacer()

                        Text("Mick MacCallum")
                    }
                }

                NavigationLink {} label: {
                    HStack {
                        Text("Email")
                            .disabled(true)

                        Spacer()

                        Text("mickm@hey.com")
                            .disabled(true)
                    }
                }
            }
        }
        .navigationTitle("Edit Profile")
    }
}
