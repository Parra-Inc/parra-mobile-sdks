//
//  Container.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

protocol Container: View {
    associatedtype Config: ContainerConfig
    associatedtype ContentObserver: ContainerContentObserver

    // Expected via init
    var config: Config { get }
    var contentObserver: ContentObserver { get }

    init(
        config: Config,
        contentObserver: ContentObserver
    )
}
