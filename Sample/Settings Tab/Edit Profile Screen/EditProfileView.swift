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
                Button(
                    action: saveChanges
                ) {
                    Label(
                        title: { Text("Save changes") },
                        icon: {
                            if isLoading {
                                ProgressView()
                            }
                        }
                    )
                }
                .disabled(isLoading)
            }
        }
        .onSubmit(of: .text) {
            saveChanges()
        }
        .navigationTitle("Edit profile")
        .onAppear {
            let userInfo = parra.user.current?.info

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
    @State private var isLoading = false

    private func saveChanges() {
        if isLoading {
            return
        }

        isLoading = true

        Task {
            do {
                try await parra.user.updatePersonalInfo(
                    name: displayName.isEmpty ? nil : displayName,
                    firstName: firstName.isEmpty ? nil : firstName,
                    lastName: lastName.isEmpty ? nil : lastName
                )
            } catch {
                Logger.error("Error saving personal info", error)
            }

            Task { @MainActor in
                isLoading = false
            }
        }
    }
}

#Preview {
    ParraAppPreview(authState: .authenticatedPreview) {
        EditProfileView()
    }
}
