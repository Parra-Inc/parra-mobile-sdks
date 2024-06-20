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
            _ result: ParraAuthResult
        ) -> Content
    ) {
        self.content = content
    }

    // MARK: - Public

    @ViewBuilder public var content: (
        _ authResult: ParraAuthResult
    ) -> Content

    @ViewBuilder public var body: some View {
        LaunchScreenWindow {
            switch parraAuthState.current {
            case .authenticated(let user):
                AnyView(authenticatedContent(for: user))
            case .unauthenticated:
                AnyView(unauthenticatedContent())
            }
        }
    }

    public func authenticatedContent(
        for user: ParraUser
    ) -> Content {
        return content(.authenticated(user))
    }

    public func unauthenticatedContent() -> some View {
        return content(.unauthenticated(nil))
    }

    // MARK: - Internal

    @EnvironmentObject var parraAuthState: ParraAuthState
    @EnvironmentObject var parraAppInfo: ParraAppInfo
}
