//
//  EditProfileViewModel.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 09/23/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import SwiftUI
import Parra

/// The Parra user manager provides a method of updating the user's name and any
/// user properties that you'd like to associate with them. User properties can
/// contain arbitrary information, subject to some limits on their key/value
/// sizes.
@Observable @MainActor final class EditProfileViewModel {
    struct Data: Equatable {
        init(
            firstName: String? = nil,
            lastName: String? = nil,
            name: String? = nil,
            birthdate: String? = nil
        ) {
            self.firstName = firstName ?? ""
            self.lastName = lastName ?? ""
            self.name = name ?? ""
            self.birthdate = if let birthdate {
                ISO8601DateFormatter().date(from: birthdate)
            } else {
                nil
            }
        }

        var firstName: String
        var lastName: String
        var name: String
        var birthdate: Date?

        var birthdateString: String? {
            if let birthdate {
                ISO8601DateFormatter().string(from: birthdate)
            } else {
                nil
            }
        }
    }

    var isDirty = false
    var isSaving = false
    var data = Data() {
        didSet {
            if data != oldValue {
                isDirty = true
            }
        }
    }

    func save(
        with parra: Parra,
        onSuccess: (() -> Void)? = nil
    ) {
        Task { @MainActor in
            if isSaving { return }

            withAnimation { isSaving = true }

            var success = true
            var properties: [String: ParraAnyCodable] = [:]
            if let birthdateString = data.birthdateString {
                properties["custom_birth_date_key"] = ParraAnyCodable(birthdateString)
            }

            do {
                try await parra.user.updateUser(
                    name: data.name,
                    firstName: data.firstName,
                    lastName: data.lastName,
                    properties: properties
                )

                ParraLogger.info("Finished saving user info")

                onSuccess?()
            } catch {
                success = false
                ParraLogger.error("Error saving user info", error)
            }

            withAnimation {
                isSaving = false
                isDirty = !success
            }
        }
    }
}
