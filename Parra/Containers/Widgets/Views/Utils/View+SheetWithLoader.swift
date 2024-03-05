//
//  View+SheetWithLoader.swift
//  Parra
//
//  Created by Mick MacCallum on 3/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension View {
    @MainActor
    func loadAndPresentSheet<Data, SheetContent>(
        loadType: Binding<ViewDataLoader<Data, SheetContent>.LoadType?>,
        with loader: ViewDataLoader<Data, SheetContent>,
        onDismiss: ((SheetDismissType) -> Void)? = nil
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
