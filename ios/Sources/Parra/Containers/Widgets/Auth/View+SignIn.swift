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
    func presentParraSignInView(
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

                authFlowManager.hasPasskeyAutoLoginBeenRequested = false

                onDismiss?(sheetType)
            }
        )
    }
}
