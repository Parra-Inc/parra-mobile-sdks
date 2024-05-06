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
    func presentParraChangelog(
        isPresented: Binding<Bool>,
        config: ChangelogWidgetConfig = .default,
        onDismiss: ((SheetDismissType) -> Void)? = nil
    ) -> some View {
        let params = ChangelogParams(
            limit: 15,
            offset: 0
        )

        let transformer: ViewDataLoader<
            ChangelogParams,
            ChangelogLoaderResult,
            ChangelogWidget
        >.Transformer = { parra, transformParams in
            let response = try await parra.parraInternal.api
                .paginateReleases(
                    limit: transformParams.limit,
                    offset: transformParams.offset
                )

            return ChangelogLoaderResult(
                appReleaseCollection: response
            )
        }

        return loadAndPresentSheet(
            loadType: .init(
                get: {
                    if isPresented.wrappedValue {
                        return .transform(params, transformer)
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
            with: .changelogLoader(
                config: config
            ),
            onDismiss: onDismiss
        )
    }
}
