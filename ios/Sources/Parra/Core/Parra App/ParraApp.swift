//
//  ParraApp.swift
//  Parra
//
//  Created by Mick MacCallum on 2/9/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger()

/// A top level wrapper around your SwiftUI app's content. When creating a
/// ``ParraApp``, you should supply it with an authentication provider and any
/// options that you would like to customize. The authentication provider is a
/// function that will be invoked periodically when Parra needs to
/// reauthenticate the user. This mechanism allows for Parra's authentication of
/// a user to be linked to their authentication with your backend. This function
/// is expected to resolve to an access token generated by your backend.
///
/// ## Example
/// Update your `@main` `App` declaration to a final class that inherits from
/// ``ParraApp``. You can indicate the classes that should be used for both your
/// app's `AppDelegate` and `SceneDelegate` by providing them as type parameters
/// on ``ParraApp``. If you have custom app/scene delegate implementations, they
/// will need to be updated to inherit from ``ParraAppDelegate`` and
/// ``ParraSceneDelegate`` respectively.
///
/// ```
/// import Parra
///
/// @main
/// final class SampleApp: ParraApp<ParraAppDelegate, ParraSceneDelegate> {
///     required init() {
///         super.init()
///
///         self.configureParra(
///             authConfiguration: // ...,
///             appContent: {
///                 ContentView()
///             }
///         )
///     }
/// }
/// ```
@MainActor
public struct ParraApp<
    Content: Scene,
    SceneDelegateClass: ParraSceneDelegate
>: Scene {
    // MARK: - Lifecycle

    public init() {
        fatalError(
            "Parra must be initialized using init(tenantId:applicationId:appDelegate:)"
        )
    }

    /// The required initializer for a ParraApp. This struct is the root of your
    /// application and should be placed at the root of the `body` of your
    /// `@main` App instance.
    /// - Parameters:
    ///   - tenantId: You can find your tenant ID at https://parra.io/dashboard/settings
    ///   - applicationId: You can find your application ID at https://parra.io/dashboard/applications
    ///   - appDelegate: A reference to the App Delegate. This is required for
    ///   Parra to access information like push tokens and scene states. You can
    ///   find more information about setting this up here:
    ///   https://docs.parra.io/sdks/ios/configuration#using-a-custom-app-or-scene-delegate
    ///   - configuration: An object allowing for the configuration of various
    ///   Parra modules.
    ///   - makeScene: A closure that results in your Scene. This is usually a
    ///   WindowGroup wrapping a Parra auth window wrapping your content view.
    @MainActor
    public init(
        tenantId: String,
        applicationId: String,
        appDelegate: ParraAppDelegate<SceneDelegateClass>,
        configuration: ParraConfiguration = .init(),
        @SceneBuilder makeScene: @MainActor @escaping () -> Content
    ) {
        ParraAppState.shared = ParraAppState(
            tenantId: tenantId,
            applicationId: applicationId
        )

        self.makeScene = makeScene

        let parraInternal = ParraInternal.createParraInstance(
            appState: ParraAppState.shared,
            // TODO: Support for other auth types
            authenticationMethod: .parra,
            configuration: configuration
        )

        // Must be set before initializing app delegate instances, which rely
        // on it.
        Parra.default.parraInternal = parraInternal

        self.parraInternal = parraInternal

        self._alertManager = State(
            wrappedValue: parraInternal.alertManager
        )

        self._launchScreenState = State(
            wrappedValue: LaunchScreenStateManager(
                state: .initial(configuration.launchScreenOptions)
            )
        )
    }

    // MARK: - Public

    public var body: some Scene {
        makeScene()
            .environment(\.parra, Parra.default)
            .environment(\.parraAuthState, authStateManager.current)
            .environment(\.parraTheme, themeManager.current)
            .environment(
                \.parraPreferredAppearance,
                themeManager.preferredAppearanceBinding
            )
            .environment(alertManager)
            .environment(launchScreenState)
            .environment(parraInternal.globalComponentFactory)
            .onChange(
                of: launchScreenState.current,
                initial: true
            ) { oldValue, newValue in
                switch (oldValue, newValue) {
                case (.initial, .initial):
                    // Should only run once on app launch.
                    performAppLaunchTasks()
                case (.initial, .transitioning(let result, _)):
                    Task {
                        // performAppLaunchTasks completing changes the launch
                        // screen state to transitioning, allowing this to start
                        await authStateManager.performInitialAuthCheck(
                            using: parraInternal.authService,
                            appInfo: result.appInfo
                        )
                    }
                default:
                    break
                }
            }
            .onChange(
                of: authStateManager.current,
                onAuthStateChanged
            )
            .onChange(
                of: scenePhase
            ) { oldPhase, newPhase in
                // If the launch screen is in the failed state, retry performing
                // launch actions each time the app enters the foreground.
                if newPhase == .active && oldPhase != .active {
                    if case .failed = launchScreenState.current {
                        performAppLaunchTasks()
                    }
                }
            }
    }

    // MARK: - Private

    @Environment(\.scenePhase) private var scenePhase

    @SceneBuilder private let makeScene: @MainActor () -> Content

    @State private var launchScreenState: LaunchScreenStateManager
    @State private var alertManager: AlertManager
    @State private var authStateManager: ParraAuthStateManager = .shared
    @State private var themeManager: ParraThemeManager = .shared

    private let parraInternal: ParraInternal

    private func onAuthStateChanged(
        from oldAuthResult: ParraAuthState,
        to authResult: ParraAuthState
    ) {
        Task {
            await parraInternal.authStateDidChange(
                from: oldAuthResult,
                to: authResult
            )
        }
    }

    private func performAppLaunchTasks() {
        Task(priority: .userInitiated) { @MainActor in // must remain main actor
            guard case .initial = launchScreenState.current else {
                return
            }

            logger.debug("Performing app launch tasks")

            let configuration = parraInternal.configuration
            ParraThemeManager.shared.current = configuration.theme

            do {
                let result = try await parraInternal
                    .performActionsRequiredForAppLaunch()

                logger.debug("Post app launch actions complete")

                logger.info("Parra SDK Initialized")

                launchScreenState.dismiss(
                    with: result,
                    launchScreenOptions: configuration.launchScreenOptions
                )

                logger.debug("Launch screen dismissed")
            } catch {
                logger.fatal(
                    "Failed to perform post app launch actions",
                    error
                )

                // This is unrecoverable. Force a logout.

                await parraInternal.authService.forceLogout(from: error)

                launchScreenState.fail(
                    userMessage: "Failed to perform actions necessary to launch app.",
                    underlyingError: error
                )
            }
        }
    }
}
