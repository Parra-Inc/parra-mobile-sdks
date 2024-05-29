//
//  ParraOptionalAuthView.swift
//  Parra
//
//  Created by Mick MacCallum on 4/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraOptionalAuthView<Content>: ParraAppContent
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
        switch parraAuthState.current {
        case .authenticated(let user):
            authenticatedContent(for: user)
        case .unauthenticated:
            unauthenticatedContent(with: parraAppInfo)
        }
    }

    public func authenticatedContent(
        for user: ParraUser
    ) -> Content {
        return content(.authenticated(user))
    }

    public func unauthenticatedContent(
        with appInfo: ParraAppInfo
    ) -> some View {
        return content(.unauthenticated(nil))
    }

    // MARK: - Internal

    @EnvironmentObject var parraAuthState: ParraAuthState
    @EnvironmentObject var parraAppInfo: ParraAppInfo
}
