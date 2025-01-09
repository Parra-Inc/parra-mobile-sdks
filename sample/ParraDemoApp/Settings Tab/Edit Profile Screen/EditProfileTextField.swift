//
//  EditProfileTextField.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 01/09/2025.
//  Copyright © 2025 Parra Inc.. All rights reserved.
//

import SwiftUI

struct EditProfileTextField: View {
    let name: String
    var value: Binding<String>

    var body: some View {
        HStack {
            Text(name)

            Spacer()

            TextField(
                name,
                text: value,
                prompt: Text(name)
            )
            .multilineTextAlignment(.trailing)
            .submitLabel(.done)
        }
    }
}
