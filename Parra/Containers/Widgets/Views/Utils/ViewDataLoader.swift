//
//  ViewDataLoader.swift
//  Parra
//
//  Created by Mick MacCallum on 3/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

@MainActor
public struct ViewDataLoader<Data, ViewContent> where ViewContent: View,
    Data: Equatable
{
    // MARK: - Lifecycle

    init(
        loader: @escaping (Parra, LoadType) async throws -> Data,
        @ViewBuilder renderer: @MainActor @escaping (Parra, Data, Dismisser?)
            -> ViewContent
    ) {
        self.load = loader
        self.render = renderer
    }

    // MARK: - Internal

    enum LoadType: Equatable {
        case id(String)
        case data(Data)
    }

    typealias Dismisser = @MainActor (SheetDismissType) -> Void

    @ViewBuilder let render: @MainActor (Parra, Data, Dismisser?) -> ViewContent

    let load: (Parra, LoadType) async throws -> Data
}
