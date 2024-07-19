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
        VStack {
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
            }
            .onSubmit(of: .text) {
                saveChanges()
            }

            Button(
                action: saveChanges
            ) {
                Label(
                    title: { Text("Save changes") },
                    icon: {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                                .padding(.trailing, 5)
                        } else if isShowingSuccess {
                            Image(systemName: "checkmark")
                        }
                    }
                )
                .frame(maxWidth: .infinity)
                .padding()
            }
            .background(.blue)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .safeAreaPadding()
            .disabled(isLoading)
        }
        .background(themeObserver.theme.palette.secondaryBackground)
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
    @EnvironmentObject private var themeObserver: ParraThemeObserver

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var displayName: String = ""
    @State private var isLoading = false
    @State private var isShowingSuccess = false

    private func saveChanges() {
        if isLoading {
            return
        }

        withAnimation {
            isLoading = true
            isShowingSuccess = false
        }

        Task { @MainActor in
            var success = true

            do {
                try await parra.user.updatePersonalInfo(
                    name: displayName.isEmpty ? nil : displayName,
                    firstName: firstName.isEmpty ? nil : firstName,
                    lastName: lastName.isEmpty ? nil : lastName
                )
            } catch {
                success = false
                Logger.error("Error saving personal info", error)
            }
            withAnimation {
                isLoading = false
                isShowingSuccess = success
            } completion: {
                if isShowingSuccess {
                    withAnimation(.easeInOut.delay(1.0)) {
                        isShowingSuccess = false
                    }
                }
            }
        }
    }
}

#Preview {
    ParraAppPreview(authState: .authenticatedPreview) {
        EditProfileView()
    }
}
