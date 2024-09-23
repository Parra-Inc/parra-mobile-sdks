//
//  EditProfileTextField.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
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
