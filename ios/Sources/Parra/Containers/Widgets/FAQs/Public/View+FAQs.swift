//
//  View+FAQs.swift
//  Parra
//
//  Created by Mick MacCallum on 12/3/24.
//

import SwiftUI

public extension View {
    /// Automatically fetches FAQs and presents them in a sheet based on the
    /// value of the `isPresented` binding.
    @MainActor
    func presentParraFAQView(
        presentationState: Binding<ParraSheetPresentationState>,
        config: ParraFAQConfiguration = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        let transformParams = FAQsTransformParams()

        let transformer: ParraViewDataLoader<
            FAQsTransformParams,
            FAQsParams,
            UserSettingsWidget
        >.Transformer = { parra, _ in
            let layout = try await parra.parraInternal.api.getFAQLayout()

            return FAQsParams(
                layout: layout
            )
        }

        return loadAndPresentSheet(
            name: "faqs",
            presentationState: presentationState,
            transformParams: transformParams,
            transformer: transformer,
            with: .faqsLoader(
                config: config
            ),
            onDismiss: onDismiss
        )
    }
}
