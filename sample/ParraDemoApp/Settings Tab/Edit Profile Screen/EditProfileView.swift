//
//  EditProfileView.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 01/09/2025.
//  Copyright © 2025 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

struct EditProfileView: View {
    @Environment(\.parra) private var parra
    @Environment(\.parraAuthState) private var parraAuthState
    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.parraUserProperties) private var parraUserProperties
    @Environment(\.presentationMode) var presentationMode

    @State private var dataModel = EditProfileViewModel()

    var body: some View {
        Form {
            Section("Name") {
                EditProfileTextField(
                    name: "First Name",
                    value: $dataModel.data.firstName
                )
                EditProfileTextField(
                    name: "Last Name",
                    value: $dataModel.data.lastName
                )
                EditProfileTextField(
                    name: "Display Name",
                    value: $dataModel.data.name
                )
            }

            Section("Personal Info") {
                DatePicker(
                    "Birthday",
                    selection: Binding<Date>(
                        get: { dataModel.data.birthdate ?? Date() },
                        set: { dataModel.data.birthdate = $0 }
                    ),
                    in: ...Date.now,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .tint(parraTheme.palette.primary)
            }
        }
        .onSubmit(of: .text) { dataModel.save(with: parra) }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled(dataModel.isDirty)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(dataModel.isDirty ? "Cancel" : "Close") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dataModel.save(with: parra) {
                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    if dataModel.isSaving {
                        ProgressView()
                    } else {
                        Text("Save")
                    }
                }
                .disabled(!dataModel.isDirty)
            }
        }
        .onAppear {
            let userInfo = parraAuthState.user?.info
            let birthdate = parraUserProperties.string(
                for: "custom_birth_date_key"
            )

            // Create our data object using an aggregation of Parra user info
            // and custom set user properties.
            dataModel.data = EditProfileViewModel.Data(
                firstName: userInfo?.firstName,
                lastName: userInfo?.lastName,
                name: userInfo?.name,
                birthdate: birthdate
            )
            dataModel.isDirty = false
        }
    }
}

#Preview {
    ParraAppPreview(authState: .authenticatedPreview) {
        EditProfileView()
    }
}
