//
//  ParraAuthDefaultEmailInputScreen.swift
//  Parra
//
//  Created by Mick MacCallum on 5/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ParraAuthDefaultEmailInputScreen: View {
    // MARK: - Lifecycle

    init(
        submitEmail: @escaping (_ email: String) -> Void
    ) {
        self.submitEmail = submitEmail
    }

    // MARK: - Internal

    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .padding()
                .background(Color.gray)
                .cornerRadius(8)

            Button("Submit") {
                submitEmail(email)
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }

    // MARK: - Private

    private let submitEmail: (_ email: String) -> Void

    @State private var email = ""
}
