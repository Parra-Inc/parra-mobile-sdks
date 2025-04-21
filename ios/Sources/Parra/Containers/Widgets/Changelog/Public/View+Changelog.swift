//
//  View+Changelog.swift
//  Parra
//
//  Created by Mick MacCallum on 3/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension View {
    /// Automatically fetches the feedback form with the provided id and
    /// presents it in a sheet based on the value of the `isPresented` binding.
    @MainActor
    func presentParraChangelogWidget(
        presentationState: Binding<ParraSheetPresentationState>,
        config: ParraChangelogWidgetConfig = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        let transformParams = ChangelogParams(
            limit: 15,
            offset: 0
        )

        let transformer: ParraViewDataLoader<
            ChangelogParams,
            ParraChangelogInfo,
            ChangelogWidget
        >.Transformer = { parra, transformParams in
            let response = try await parra.parraInternal.api.paginateReleases(
                limit: transformParams.limit,
                offset: transformParams.offset
            )

            return ParraChangelogInfo(
                appReleaseCollection: response
            )
        }

        return loadAndPresentSheet(
            name: "changelog",
            presentationState: presentationState,
            transformParams: transformParams,
            transformer: transformer,
            with: .changelogLoader(
                config: config
            ),
            onDismiss: onDismiss
        )
    }

    @MainActor
    func presentParraChangelogWidget(
        with dataBinding: Binding<ParraChangelogInfo?>,
        config: ParraChangelogWidgetConfig = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        return presentSheetWithData(
            data: dataBinding,
            config: config,
            with: ParraContainerRenderer.changelogRenderer,
            onDismiss: onDismiss
        )
    }
}
