//
//  EditProfileTextField.swift
//  ParraDev
//
//  Created by Mick MacCallum on 9/23/24.
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
