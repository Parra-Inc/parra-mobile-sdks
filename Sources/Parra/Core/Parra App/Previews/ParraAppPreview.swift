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
    where Content: View, DelegateType: ParraAppDelegate
{
    // MARK: - Lifecycle

    public init(
        configuration: ParraConfiguration = .init(),
        previewContent: @MainActor @escaping () -> Content
    ) {
        self.configuration = configuration
        self.previewContent = previewContent
        self._parraAuthState = StateObject(
            wrappedValue: ParraAuthState()
        )

        let appState = ParraAppState(
            tenantId: Parra.Demo.workspaceId,
            applicationId: Parra.Demo.applicationId
        )

        self.parra = Parra(
            parraInternal: ParraInternal
                .createParraSwiftUIPreviewsInstance(
                    appState: appState,
                    authenticationMethod: .preview,
                    configuration: configuration
                )
        )
    }

    // MARK: - Public

    public var body: some View {
        ParraOptionalAuthWindow { _ in
            previewContent()
        }
        .environment(\.parra, parra)
        .environmentObject(parraAuthState)
//        .environmentObject(ParraAppInfo) // TODO: Need this?
    }

    // MARK: - Private

    private let configuration: ParraConfiguration
    private let previewContent: () -> Content
    private let parra: Parra

    @StateObject private var parraAuthState: ParraAuthState
}
