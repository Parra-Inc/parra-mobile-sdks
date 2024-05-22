//
//  ParraAuthDefaultIdentityChallengeScreen.swift
//  Parra
//
//  Created by Mick MacCallum on 5/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraAuthDefaultIdentityChallengeScreen: ParraAuthScreen {
    // MARK: - Lifecycle

    public init(params: Params) {
        self.params = params
    }

    // MARK: - Public

    public struct Params: ParraAuthScreenParams {
        // MARK: - Lifecycle

        public init(
            userExists: Bool,
            availableChallenges: [ParraAuthChallenge],
            submit: @escaping (_ challengeResponse: ChallengeResponse) -> Void
        ) {
            self.userExists = userExists
            self.availableChallenges = availableChallenges
            self.submit = submit
        }

        // MARK: - Public

        public let userExists: Bool
        public let availableChallenges: [ParraAuthChallenge]
        public let submit: (_ challengeResponse: ChallengeResponse) -> Void
    }

    public var body: some View {
        VStack {
            Text("params: \(params)")

            TextField("Password", text: $response)
                .padding()
                .background(Color.gray)
                .cornerRadius(8)

            Button("Submit") {
//                params.submit(.password($response))
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            Button("Login without password") {
                submitChallengeResponse()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }

    // MARK: - Private

    private let params: Params

    @State private var response = ""

    @EnvironmentObject private var componentFactory: ComponentFactory
    @EnvironmentObject private var themeObserver: ParraThemeObserver
    @EnvironmentObject private var navigationState: NavigationState

    private func submitChallengeResponse() {
//        switch params.challengeType {
//        case .password:
//            params.submit(.password(response))
//        case .passwordlessEmail:
//            params.submit(.passwordlessEmail(response))
//        case .passwordlessSms:
//            params.submit(.passwordlessSms(response))
//        }
    }
}
