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
    func loadAndPresentSheet<TransformParams, Data, SheetContent>(
        loadType: Binding<
            ParraViewDataLoader<TransformParams, Data, SheetContent>
                .LoadType?
        >,
        with loader: ParraViewDataLoader<TransformParams, Data, SheetContent>,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        modifier(
            SheetWithLoader(
                loadType: loadType,
                loader: loader,
                onDismiss: onDismiss
            )
        )
    }
}
