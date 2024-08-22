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
        content: @escaping () -> Content
    ) {
        self.content = content
    }

    // MARK: - Public

    @ViewBuilder public var content: () -> Content

    @ViewBuilder public var body: some View {
        LaunchScreenWindow {
            switch parraAuthState {
            case .authenticated, .anonymous:
                AnyView(authenticatedContent())
            case .undetermined, .error, .guest:
                AnyView(unauthenticatedContent())
            }
        }
    }

    public func authenticatedContent() -> Content {
        return content()
    }

    public func unauthenticatedContent() -> some View {
        return content()
    }

    // MARK: - Private

    @Environment(\.parraAuthState) private var parraAuthState
}
