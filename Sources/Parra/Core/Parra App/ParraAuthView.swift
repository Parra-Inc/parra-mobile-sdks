//
//  ParraAuthView.swift
//  Parra
//
//  Created by Mick MacCallum on 4/12/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraUser: Equatable, Codable {
    let credential: ParraCredential

    // TODO: this
    let userInfo: [String: String]?
}

struct ParraAuthenticationView: View {
    // MARK: - Lifecycle

    init(error: Error? = nil) {
        self.error = error
    }

    // MARK: - Internal

    var error: Error?

    var body: some View {
        EmptyView()
    }
}

struct ParraOptionalAuthView<Content>: View where Content: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
    }
}

struct ParraAuthView<AuthContent, UnauthContent>: View
    where AuthContent: View, UnauthContent: View
{
    // MARK: - Lifecycle

    init(
        authenticatedContent: @escaping (_ user: ParraUser) -> AuthContent,
        unauthenticatedContent: @escaping () -> UnauthContent = {
            ParraAuthenticationView()
        }
    ) {
        self.authenticatedContent = authenticatedContent
        self.unauthenticatedContent = unauthenticatedContent
    }

    // MARK: - Internal

    @Environment(\.parra) var parra

    @ViewBuilder var authenticatedContent: (_ user: ParraUser) -> AuthContent
    @ViewBuilder var unauthenticatedContent: () -> UnauthContent

    var body: some View {
        if let currentUser = parra.parraInternal.currentUser {
            authenticatedContent(currentUser)

        } else {
            unauthenticatedContent()
        }
    }
}

#Preview {
    ParraAuthView { _ in
        EmptyView()
    }
}
