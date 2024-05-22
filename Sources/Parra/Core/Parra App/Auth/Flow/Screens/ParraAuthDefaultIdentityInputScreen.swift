//
//  ParraAuthDefaultIdentityInputScreen.swift
//  Parra
//
//  Created by Mick MacCallum on 5/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraAuthDefaultIdentityInputScreen: ParraAuthScreen {
    // MARK: - Lifecycle

    public init(
        params: Params
    ) {
        self.params = params
    }

    // MARK: - Public

    public struct Params: ParraAuthScreenParams {
        // MARK: - Lifecycle

        public init(
            // basically whether to show "email" "phone number" or "email or phone number" in the placeholder
            passwordlessMethods: [AuthenticationMethod.PasswordlessType],
            submit: @escaping (_ identity: String) async throws -> Void
        ) {
            self.passwordlessMethods = passwordlessMethods
            self.submit = submit
        }

        // MARK: - Public

        public let passwordlessMethods: [AuthenticationMethod.PasswordlessType]
        public let submit: (_ identity: String) async throws -> Void
    }

    public var body: some View {
        VStack {
            TextField("Email", text: $identity)
                .padding()
                .background(Color.gray)
                .cornerRadius(8)

            Button("Submit") {
                Task {
                    do {
                        try await params.submit(identity)
                    } catch {
                        print(error)
                    }
                }
//                submitEmail(email)
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .applyDefaultWidgetAttributes(
            using: themeObserver.theme
        )
    }

    // MARK: - Private

    @State private var identity = ""
    private let params: Params

    @EnvironmentObject private var componentFactory: ComponentFactory
    @EnvironmentObject private var themeObserver: ParraThemeObserver
    @EnvironmentObject private var navigationState: NavigationState
}
