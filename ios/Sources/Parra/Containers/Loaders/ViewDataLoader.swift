//
//  ViewDataLoader.swift
//  Parra
//
//  Created by Mick MacCallum on 3/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

@MainActor
struct ViewDataLoader<TransformParams, Data, ViewContent>
    where ViewContent: View, Data: Equatable, TransformParams: Equatable
{
    // MARK: - Lifecycle

    init(
        @ViewBuilder renderer: @MainActor @escaping (Parra, Data, Dismisser?)
            -> ViewContent
    ) {
        self.render = renderer
    }

    // MARK: - Internal

    typealias Transformer = (Parra, TransformParams) async throws -> Data

    enum LoadType: Equatable {
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

        // MARK: - Internal

        static func == (
            lhs: ViewDataLoader<TransformParams, Data, ViewContent>.LoadType,
            rhs: ViewDataLoader<TransformParams, Data, ViewContent>.LoadType
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

    typealias Dismisser = @MainActor (ParraSheetDismissType) -> Void

    @ViewBuilder let render: @MainActor (Parra, Data, Dismisser?) -> ViewContent
}
