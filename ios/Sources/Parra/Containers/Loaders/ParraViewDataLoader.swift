//
//  ParraViewDataLoader.swift
//  Parra
//
//  Created by Mick MacCallum on 3/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public typealias ParraSheetDismisser = @MainActor (ParraSheetDismissType) -> Void

@MainActor
public struct ParraViewDataLoader<TransformParams, Data, ViewContent>
    where ViewContent: View, Data: Equatable, TransformParams: Equatable
{
    // MARK: - Lifecycle

    public init(
        @ViewBuilder renderer: @MainActor @escaping (
            Parra,
            Data,
            Binding<NavigationPath>,
            ParraSheetDismisser?
        ) -> ViewContent
    ) {
        self.render = renderer
    }

    // MARK: - Public

    public typealias Transformer = (Parra, TransformParams) async throws -> Data

    // MARK: - Internal

    @ViewBuilder let render: @MainActor (
        Parra,
        Data,
        Binding<NavigationPath>,
        ParraSheetDismisser?
    ) -> ViewContent
}
