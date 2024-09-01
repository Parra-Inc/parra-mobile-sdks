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
        authState: ParraAuthState = .undetermined,
        previewContent: @MainActor @escaping () -> Content
    ) {
        self.configuration = configuration
        self.previewContent = previewContent
        self._authStateManager = State(
            initialValue: ParraAuthStateManager(
                current: authState
            )
        )

        ParraAppState.shared = ParraAppState(
            tenantId: ParraInternal.Demo.tenantId,
            applicationId: ParraInternal.Demo.applicationId
        )

        let parraInternal = ParraInternal
            .createParraSwiftUIPreviewsInstance(
                appState: ParraAppState.shared,
                authenticationMethod: .preview,
                configuration: configuration
            )

        self.parra = Parra(
            parraInternal: parraInternal
        )

        self._alertManager = State(
            wrappedValue: parraInternal.alertManager
        )

        ParraThemeManager.shared.current = parraInternal.configuration.theme
    }

    // MARK: - Public

    public var body: some View {
        ParraOptionalAuthWindow {
            previewContent()
        }
        .environment(\.parra, parra)
        .environment(\.parraAuthState, authStateManager.current)
        .environment(\.parraTheme, themeManager.current)
        .environment(\.parraPreferredAppearance, themeManager.preferredAppearanceBinding)
        .environment(alertManager)
        .environment(
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

    @State private var alertManager: AlertManager
    @State private var authStateManager: ParraAuthStateManager
    @State private var themeManager: ParraThemeManager = .shared
}
