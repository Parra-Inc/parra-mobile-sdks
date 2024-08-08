//
//  ParraOptionalAuthWindow.swift
//  Parra
//
//  Created by Mick MacCallum on 4/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraOptionalAuthWindow<Content>: ParraAppContent
    where Content: View
{
    // MARK: - Lifecycle

    public init(
        content: @escaping (
            _ result: ParraAuthState
        ) -> Content
    ) {
        self.content = content
    }

    // MARK: - Public

    @ViewBuilder public var content: (
        _ authResult: ParraAuthState
    ) -> Content

    @ViewBuilder public var body: some View {
        LaunchScreenWindow {
            switch parraAuthState {
            case .authenticated(let user), .anonymous(let user):
                AnyView(authenticatedContent(for: user))
            case .undetermined, .error, .guest:
                AnyView(unauthenticatedContent())
            }
        }
    }

    public func authenticatedContent(
        for user: ParraUser
    ) -> Content {
        return content(parraAuthState)
    }

    public func unauthenticatedContent() -> some View {
        return content(parraAuthState)
    }

    // MARK: - Internal

    @Environment(\.parraAuthState) private var parraAuthState
    @Environment(\.parraAppInfo) private var parraAppInfo
}
