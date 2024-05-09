//
//  ParraAuthDefaultLandingScreen.swift
//  Parra
//
//  Created by Mick MacCallum on 5/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ParraAuthDefaultLandingScreen: View {
    // MARK: - Lifecycle

    init(
        selectLoginMethod: @escaping (LoginMethod) -> Void
    ) {
        self.selectLoginMethod = selectLoginMethod
    }

    // MARK: - Internal

    var body: some View {
        VStack {
            Button("Login with Email or Phone") {
                selectLoginMethod(.emailOrPhone)
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            Button("Login with Google") {
                selectLoginMethod(.sso(.google))
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            Button("Login with Apple") {
                selectLoginMethod(.sso(.apple))
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            Button("Login with Facebook") {
                selectLoginMethod(.sso(.facebook))
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }

    // MARK: - Private

    private let selectLoginMethod: (LoginMethod) -> Void
}
