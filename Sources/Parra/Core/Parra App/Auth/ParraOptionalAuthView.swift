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
        content: @escaping (_ result: ParraAuthResult) -> Content
    ) {
        self.content = content
    }

    // MARK: - Public

    @ViewBuilder public var content: (_ authResult: ParraAuthResult) -> Content

    public var body: some View {
        switch authState.current {
        case .authenticated(let user):
            return authenticatedContent(for: user)
        case .unauthenticated(let error):
            return unauthenticatedContent(for: error)
        }
    }

    public func authenticatedContent(for user: ParraUser) -> Content {
        return content(.authenticated(user))
    }

    public func unauthenticatedContent(for error: (any Error)?) -> Content {
        return content(.unauthenticated(error))
    }

    // MARK: - Private

    @Environment(\.parraAuthState) private var authState
}
