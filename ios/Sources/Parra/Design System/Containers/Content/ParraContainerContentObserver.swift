//
//  ParraContainerContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

@MainActor
public protocol ParraContainerContentObserver: ObservableObject {
    associatedtype Content: ParraContainerContent
    associatedtype InitialParams

    var content: Content { get }

    init(initialParams: InitialParams)
}
