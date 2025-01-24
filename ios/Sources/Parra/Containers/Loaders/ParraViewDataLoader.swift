//
//  ParraViewDataLoader.swift
//  Parra
//
//  Created by Mick MacCallum on 3/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

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
            Dismisser?
        )
            -> ViewContent
    ) {
        self.render = renderer
    }

    // MARK: - Public

    public typealias Transformer = (Parra, TransformParams) async throws -> Data

    public enum LoadType: Equatable {
        // A function that allows for transformation of the data as long as it
        // results in the content that the widget expects to display. Usually
        // this is used for fetching data from the network.
        // Note: The Transform Params passed here are basically just passed
        // right back to the transformer function at the call site but we needed
        // a way for LoadType to be Equatable, and the TransformParams are
        // being different indicates the function is different.
        case transform(TransformParams, Transformer)

        // The data we want to display already exists at the call site so it can
        // be used directly.
        case raw(Data)

        // MARK: - Public

        public static func == (
            lhs: ParraViewDataLoader<TransformParams, Data, ViewContent>.LoadType,
            rhs: ParraViewDataLoader<TransformParams, Data, ViewContent>.LoadType
        ) -> Bool {
            switch (lhs, rhs) {
            case (.transform(let lhsParams, _), .transform(let rhsParams, _)):
                return lhsParams == rhsParams
            case (.raw(let lData), .raw(let rData)):
                return lData == rData
            default:
                return false
            }
        }
    }

    public typealias Dismisser = @MainActor (ParraSheetDismissType) -> Void

    // MARK: - Internal

    @ViewBuilder let render: @MainActor (
        Parra,
        Data,
        Binding<NavigationPath>,
        Dismisser?
    ) -> ViewContent
}
