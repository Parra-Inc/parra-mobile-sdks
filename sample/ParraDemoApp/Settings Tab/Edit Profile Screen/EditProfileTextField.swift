//
//  EditProfileTextField.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 12/30/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
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
