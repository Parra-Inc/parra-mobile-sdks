//
//  EditProfileView.swift
//  Sample
//
//  Created by Mick MacCallum on 7/19/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Parra
import SwiftUI

struct EditProfileView: View {
    // MARK: - Internal

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("First name")
                    Spacer()
                        .frame(maxWidth: .infinity)
                    TextField(
                        "First name",
                        text: $firstName,
                        prompt: Text("First name")
                    )
                    .multilineTextAlignment(.trailing)
                }

                HStack {
                    Text("Last name")
                    Spacer()
                        .frame(maxWidth: .infinity)
                    TextField(
                        "Last name",
                        text: $lastName,
                        prompt: Text("Last name")
                    )
                    .multilineTextAlignment(.trailing)
                }

                HStack {
                    Text("Display name")
                    Spacer()
                        .frame(maxWidth: .infinity)
                    TextField(
                        "Display name",
                        text: $displayName,
                        prompt: Text("Display name")
                    )
                    .multilineTextAlignment(.trailing)
                }
            }

            Section {
                Button(action: {
                    parra.currentUser
                }, label: {
                    Text("Save changes")
                })
            }
        }
        .navigationTitle("Edit profile")
        .onAppear {
            let userInfo = parra.currentUser?.info

            firstName = userInfo?.firstName ?? ""
            lastName = userInfo?.lastName ?? ""
            displayName = userInfo?.name ?? ""
        }
    }

    // MARK: - Private

    @Environment(\.parra) private var parra

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var displayName: String = ""
}

#Preview {
    ParraAppPreview(authState: .authenticatedPreview) {
        EditProfileView()
    }
}
