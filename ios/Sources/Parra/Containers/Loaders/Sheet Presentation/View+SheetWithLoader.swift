//
//  View+SheetWithLoader.swift
//  Parra
//
//  Created by Mick MacCallum on 3/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension View {
    @MainActor
    func presentSheetWithData<Data, Container: ParraContainer>(
        data: Binding<Data?>,
        config: Container.Config,
        @ViewBuilder with renderer: @MainActor @escaping (
            _ config: Container.Config,
            _ parra: Parra,
            _ data: Data,
            _ navigationPath: Binding<NavigationPath>,
            _ dismisser: ParraSheetDismisser?
        ) -> Container,
        detents: Set<PresentationDetent> = [],
        visibility: Visibility = .automatic,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View where Data: Equatable {
        return modifier(
            SheetWithData<Data, Container>(
                data: data,
                config: config,
                with: renderer,
                detents: detents,
                visibility: visibility,
                onDismiss: onDismiss
            )
        )
    }

    @MainActor
    func loadAndPresentSheet<TransformParams, Data, SheetContent>(
        name: String,
        presentationState: Binding<ParraSheetPresentationState>,
        transformParams: TransformParams,
        transformer: @escaping ParraViewDataLoader<TransformParams, Data, SheetContent>
            .Transformer,
        with loader: ParraViewDataLoader<TransformParams, Data, SheetContent>,
        detents: Set<PresentationDetent> = [],
        visibility: Visibility = .automatic,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View where SheetContent: View {
        return modifier(
            SheetWithLoader(
                name: name,
                presentationState: presentationState,
                transformParams: transformParams,
                transformer: transformer,
                loader: loader,
                detents: detents,
                visibility: visibility,
                onDismiss: onDismiss
            )
        )
    }
}
