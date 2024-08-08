//
//  View+SignIn.swift
//  Parra
//
//  Created by Mick MacCallum on 8/5/24.
//

import SwiftUI

struct ParraSignInModal: View {
    // MARK: - Lifecycle

    init(
        config: ParraAuthenticationFlowConfig,
        complete: @escaping () -> Void
    ) {
        self.config = config
        self.complete = complete
    }

    // MARK: - Internal

    let config: ParraAuthenticationFlowConfig
    let complete: () -> Void

    @ViewBuilder var body: some View {
        VStack {
            ParraDefaultAuthenticationFlowView(
                flowConfig: config
            )
        }
        .onChange(
            of: parraAuthState
        ) { oldValue, newValue in
            if !oldValue.isLoggedIn && newValue.isLoggedIn {
                complete()
            }
        }
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
    @Environment(\.parraAuthState) private var parraAuthState
}

public extension View {
    /// Presents a modal sheet containing the Parra sign in view. This is only
    /// available if you're using Parra Auth.
    @MainActor
    func presentParraSignInView(
        isPresented: Binding<Bool>,
        config: ParraAuthenticationFlowConfig = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        return presentSheet(
            isPresented: isPresented,
            content: {
                ParraSignInModal(
                    config: config,
                    complete: {
                        isPresented.wrappedValue = false
                    }
                )
            },
            onDismiss: { sheetType in
                AuthenticationFlowManager.shared.hasPasskeyAutoLoginBeenRequested = false

                onDismiss?(sheetType)
            }
        )
    }
}

