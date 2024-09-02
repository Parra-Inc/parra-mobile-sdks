//
//  EditProfileView.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 09/02/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

struct EditProfileView: View {
    @Environment(\.parra) private var parra
    @Environment(\.parraAuthState) private var parraAuthState
    @Environment(\.parraTheme) private var parraTheme

    @State private var data = ProfileData()
    @State private var isLoading = false
    @State private var isShowingSuccess = false

    var body: some View {
        VStack {
            Form {
                Section {
                    formField(named: "First Name", fieldData: $data.firstName)
                    formField(named: "Last Name", fieldData: $data.lastName)
                    formField(named: "Display Name", fieldData: $data.name)
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
                            .bold()
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
            .background(parraTheme.palette.primary.toParraColor())
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .safeAreaPadding()
            .disabled(isLoading)
        }
        .navigationTitle("Edit Profile")
        .background(parraTheme.palette.primaryBackground)
        .scrollContentBackground(.hidden)
        .onAppear {
            let userInfo = parraAuthState.user?.info

            data = ProfileData(
                firstName: userInfo?.firstName,
                lastName: userInfo?.lastName,
                name: userInfo?.name
            )
        }
    }

    private func formField(
        named name: String,
        fieldData: Binding<String>
    ) -> some View {
        HStack {
            Text(name)

            Spacer()

            TextField(
                name,
                text: fieldData,
                prompt: Text(name)
            )
            .multilineTextAlignment(.trailing)
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
                    name: data.name,
                    firstName: data.firstName,
                    lastName: data.lastName
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

    private struct ProfileData {
        init(
            firstName: String? = nil,
            lastName: String? = nil,
            name: String? = nil
        ) {
            self.firstName = firstName ?? ""
            self.lastName = lastName ?? ""
            self.name = name ?? ""
        }

        var firstName: String
        var lastName: String
        var name: String
    }
}

#Preview {
    ParraAppPreview(authState: .authenticatedPreview) {
        EditProfileView()
    }
}
