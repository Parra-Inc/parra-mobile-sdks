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
///     @Environment(Parra.self) var parra
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
        options: [ParraConfigurationOption] = [],
        previewContent: @MainActor @escaping () -> Content
    ) {
        self.options = options
        self.previewContent = previewContent
    }

    // MARK: - Public

    public var body: some View {
        ParraAppView(
            authProvider: .preview,
            options: options,
            appDelegateType: ParraAppDelegate.self,
            launchScreenConfig: .preview,
            sceneContent: previewContent
        )
    }

    // MARK: - Private

    private let options: [ParraConfigurationOption]
    private let previewContent: () -> Content
}
