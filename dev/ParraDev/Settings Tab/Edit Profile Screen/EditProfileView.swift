//
//  EditProfileView.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 08/01/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

struct EditProfileView: View {
    @Environment(\.parra) private var parra
    @EnvironmentObject private var themeManager: ParraThemeManager
    @EnvironmentObject private var parraAuthState: ParraAuthState

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var displayName: String = ""
    @State private var isLoading = false
    @State private var isShowingSuccess = false

    var user: ParraUser? {
        return parraAuthState.current.user
    }

    var body: some View {
        VStack {
            Form {
                Section {
                    HStack {
                        Text("First Name")
                        Spacer()
                            .frame(maxWidth: .infinity)
                        TextField(
                            "First Name",
                            text: $firstName,
                            prompt: Text("First Name")
                        )
                        .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Text("Last Name")
                        Spacer()
                            .frame(maxWidth: .infinity)
                        TextField(
                            "Last Name",
                            text: $lastName,
                            prompt: Text("Last Name")
                        )
                        .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Text("Display Name")
                        Spacer()
                            .frame(maxWidth: .infinity)
                        TextField(
                            "Display Name",
                            text: $displayName,
                            prompt: Text("Display Name")
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
                    title: {
                        Text(isShowingSuccess ? "Saved" : "Save")
                    },
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
        .background(themeManager.theme.palette.secondaryBackground)
        .navigationTitle("Edit Profile")
        .onAppear {
            let userInfo = user?.info

            firstName = userInfo?.firstName ?? ""
            lastName = userInfo?.lastName ?? ""
            displayName = userInfo?.name ?? ""
        }
    }

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

                ParraLogger.error("Error saving personal info", error)
            }
            
            withAnimation {
                isLoading = false
                isShowingSuccess = success
            } completion: {
                if isShowingSuccess {
                    withAnimation(.easeInOut.delay(2.0)) {
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
