//
//  View+Settings.swift
//  Parra
//
//  Created by Mick MacCallum on 11/1/24.
//

import SwiftUI

public extension View {
    /// Automatically fetches the feed with the provided id and
    /// presents it in a sheet based on the value of the `isPresented` binding.
    @MainActor
    func presentParraSettingsView(
        layoutId: String,
        isPresented: Binding<Bool>,
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
            loadType: .init(
                get: {
                    if isPresented.wrappedValue {
                        return .transform(transformParams, transformer)
                    } else {
                        return nil
                    }
                },
                set: { type in
                    if type == nil {
                        isPresented.wrappedValue = false
                    }
                }
            ),
            with: .settingsLoader(
                config: config
            ),
            onDismiss: onDismiss
        )
    }
}
