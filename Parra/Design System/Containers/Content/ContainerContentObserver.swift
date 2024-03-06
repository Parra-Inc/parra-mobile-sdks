//
//  ContainerContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

@MainActor
protocol ContainerContentObserver: ObservableObject {
    associatedtype Content: ContainerContent
    associatedtype InitialParams

    var content: Content { get }

    init(initialParams: InitialParams)
}
