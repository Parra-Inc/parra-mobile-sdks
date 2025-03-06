//
//  View+SignIn.swift
//  Parra
//
//  Created by Mick MacCallum on 8/5/24.
//

import SwiftUI

public extension View {
    /// Presents a modal sheet containing the Parra sign in view. This is only
    /// available if you're using Parra Auth.
    @MainActor
    func presentParraSignInWidget(
        isPresented: Binding<Bool>,
        config: ParraAuthenticationFlowConfig = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil,
        onComplete: (() -> Void)? = nil
    ) -> some View {
        return presentSheet(
            isPresented: isPresented,
            content: {
                ParraDefaultAuthenticationFlowView(
                    flowConfig: config
                ) {
                    isPresented.wrappedValue = false
                }
            },
            onDismiss: { sheetType in
                let authFlowManager = Parra.default.parraInternal.authFlowManager

                authFlowManager.resetAutoLoginRequested()

                onDismiss?(sheetType)
            }
        )
    }

    /// Presents a modal sheet containing the Parra sign in view. This is only
    /// available if you're using Parra Auth.
    @MainActor
    func presentParraSignInWidget(
        config: Binding<ParraAuthenticationFlowConfig?>,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil,
        onComplete: (() -> Void)? = nil
    ) -> some View {
        return presentSheet(
            isPresented: .init(
                get: {
                    return config.wrappedValue != nil
                },
                set: { isPresented in
                    if !isPresented {
                        config.wrappedValue = nil
                    }
                }
            ),
            content: {
                if let conf = config.wrappedValue {
                    ParraDefaultAuthenticationFlowView(
                        flowConfig: conf
                    ) {
                        config.wrappedValue = nil
                    }
                }
            },
            onDismiss: { sheetType in
                let authFlowManager = Parra.default.parraInternal.authFlowManager

                authFlowManager.resetAutoLoginRequested()

                onDismiss?(sheetType)
            }
        )
    }
}
