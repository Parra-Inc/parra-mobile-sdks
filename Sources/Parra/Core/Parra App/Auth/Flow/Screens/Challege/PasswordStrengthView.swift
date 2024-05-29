//
//  PasswordStrengthView.swift
//  Parra
//
//  Created by Mick MacCallum on 5/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct PasswordStrengthView: View {
    // MARK: - Internal

    @Binding var password: String
    let passwordConfig: PasswordConfig

    var body: some View {
        Group {
            VStack {}
        }
        .onChange(of: password) { _, _ in
            validate()
        }
    }

    // MARK: - Private

    private func validate() {
        password
    }
}

#Preview {
    ParraViewPreview { _ in
        VStack {
            PasswordStrengthView(
                password: .constant(""),
                passwordConfig: .validStates()[0]
            )

            PasswordStrengthView(
                password: .constant("short"),
                passwordConfig: .validStates()[0]
            )

            PasswordStrengthView(
                password: .constant("abcdefghijklm"),
                passwordConfig: .validStates()[0]
            )

            PasswordStrengthView(
                password: .constant("Gfo4FZ1-34Dy!"),
                passwordConfig: .validStates()[0]
            )
        }
    }
}
