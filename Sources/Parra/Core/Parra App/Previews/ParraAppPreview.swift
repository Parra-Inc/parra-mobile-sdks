//
//  ParraAppPreview.swift
//  Parra
//
//  Created by Mick MacCallum on 2/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

/// A ``ParraAppPreview`` is intended to be used for any SwiftUI Previews that
/// you want to build that will utilize Parra components or APIs. This View is
/// similar to ``ParraApp`` except it is preconfigured for a testing environment
/// and requires less customization. It also differs by returning a View
/// suitable for use in a Preview and not a Scene.
///
/// ## Example
///
/// ```
/// struct ExampleView: View {
///     @Environment(\.parra) var parra
///
///     var body: some View {
///         Button("Fetch cards") {
///             Task {
///                 // For example only
///                 let _ = try! await parra.feedback.fetchFeedbackCards()
///             }
///         }
///     }
/// }
///
/// #Preview {
///     ParraAppPreview {
///         ExampleView()
///     }
/// }
/// ```
///
@MainActor
public struct ParraAppPreview<Content, DelegateType>: View
    where Content: View, DelegateType: ParraAppDelegate<ParraSceneDelegate>
{
    // MARK: - Lifecycle

    public init(
        configuration: ParraConfiguration = .init(),
        authState: ParraAuthState = .init(),
        previewContent: @MainActor @escaping () -> Content
    ) {
        self.configuration = configuration
        self.previewContent = previewContent
        self._parraAuthState = StateObject(
            wrappedValue: authState
        )

        let appState = ParraAppState(
            tenantId: Parra.Demo.workspaceId,
            applicationId: Parra.Demo.applicationId
        )

        let parraInternal = ParraInternal
            .createParraSwiftUIPreviewsInstance(
                appState: appState,
                authenticationMethod: .preview,
                configuration: configuration
            )

        self.parra = Parra(
            parraInternal: parraInternal
        )

        self._alertManager = StateObject(
            wrappedValue: parraInternal.alertManager
        )

        self._themeObserver = StateObject(
            wrappedValue: ParraThemeObserver(
                theme: parraInternal.configuration.theme,
                notificationCenter: parraInternal.notificationCenter
            )
        )

        if case .authenticated(let user) = authState.current {
            parra.user.current = user
        } else {
            parra.user.current = nil
        }
    }

    // MARK: - Public

    public var body: some View {
        ParraOptionalAuthWindow { _ in
            previewContent()
        }
        .environment(\.parra, parra)
        .environmentObject(parraAuthState)
        .environmentObject(alertManager)
        .environmentObject(themeObserver)
        .environmentObject(
            LaunchScreenStateManager(
                state: .complete(
                    .init(
                        appInfo: ParraAppInfo.validStates()[0]
                    )
                )
            )
        )
    }

    // MARK: - Private

    private let configuration: ParraConfiguration
    private let previewContent: () -> Content
    private let parra: Parra

    @StateObject private var parraAuthState: ParraAuthState
    @StateObject private var alertManager: AlertManager
    @StateObject private var themeObserver: ParraThemeObserver
}
