//
//  View+CreatorUpdate.swift
//  Parra
//
//  Created by Mick MacCallum on 3/3/25.
//

import SwiftUI

public extension View {
    /// Automatically fetches the feed with the provided id and
    /// presents it in a sheet based on the value of the `isPresented` binding.
    @MainActor
    func presentParraCreatorUpdateComposer(
        feedId: String,
        presentationState: Binding<ParraSheetPresentationState>,
        config: ParraCreatorUpdateConfiguration = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        let transformParams = CreatorUpdateTransformParams(
            feedId: feedId
        )

        let transformer: ParraViewDataLoader<
            CreatorUpdateTransformParams,
            CreatorUpdateParams,
            CreatorUpdateWidget
        >.Transformer = { parra, transformParams in
            let response = try await parra.parraInternal.api
                .getCreatorUpdateTemplates()

            let templates = response.data.elements

            return CreatorUpdateParams(
                feedId: transformParams.feedId,
                templates: templates
            )
        }

        return loadAndPresentSheet(
            name: "feed",
            presentationState: presentationState,
            transformParams: transformParams,
            transformer: transformer,
            with: .creatorUpdate(
                config: config
            ),
            onDismiss: onDismiss
        )
    }
}
