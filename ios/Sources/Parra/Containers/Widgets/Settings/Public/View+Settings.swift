//
//  View+Settings.swift
//  Parra
//
//  Created by Mick MacCallum on 11/1/24.
//

import SwiftUI

public extension View {
    /// Automatically fetches the Parra managed notification settings view and
    /// presents it in a sheet, based on the value of the `isPresented` binding.
    /// The settings view presented by this conveinence modifier can be found:
    /// https://parra.io/dashboard/users/configuration
    /// with the "notifications" key.
    @MainActor
    func presentParraNotificationSettingsView(
        presentationState: Binding<ParraSheetPresentationState>,
        config: ParraUserNotificationSettingsConfiguration = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        let fullConfig = ParraUserSettingsConfiguration.default
        fullConfig.notificationSettingsConfig = config

        return presentParraSettingsView(
            layoutId: "notifications",
            presentationState: presentationState,
            config: fullConfig,
            onDismiss: onDismiss
        )
    }

    /// Automatically fetches the settings view with the provided layout id and
    /// presents it in a sheet based on the value of the `isPresented` binding.
    @MainActor
    func presentParraSettingsView(
        layoutId: String,
        presentationState: Binding<ParraSheetPresentationState>,
        config: ParraUserSettingsConfiguration = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        let transformParams = SettingsTransformParams(layoutId: layoutId)

        let transformer: ParraViewDataLoader<
            SettingsTransformParams,
            SettingsParams,
            UserSettingsWidget
        >.Transformer = { parra, _ in
            let layout = try await parra.parraInternal.api.getSettingsLayout(
                layoutId: layoutId
            )

            return SettingsParams(
                layoutId: layoutId,
                layout: layout
            )
        }

        return loadAndPresentSheet(
            name: "settings",
            presentationState: presentationState,
            transformParams: transformParams,
            transformer: transformer,
            with: .settingsLoader(
                config: config
            ),
            onDismiss: onDismiss
        )
    }
}
