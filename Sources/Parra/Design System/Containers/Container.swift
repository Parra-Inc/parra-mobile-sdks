//
//  Container.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

protocol Container: View {
    associatedtype BuilderConfig: LocalComponentBuilderConfig
    associatedtype Config: ContainerConfig
    associatedtype ContentObserver: ContainerContentObserver

    /// Should be one of:
    /// 1. ``Parra.ScreenStyle``
    /// 2. ``Parra.ToastStyle``
    /// 3. ``Parra.WidgetStyle``
    associatedtype Style: ContainerStyle

    // Expected via init
    var config: Config { get }
    var style: Style { get }
    var localBuilderConfig: BuilderConfig { get }
    var componentFactory: ComponentFactory { get }
    var contentObserver: ContentObserver { get }

    // Expected via @Environment
    var themeObserver: ParraThemeObserver { get }

    init(
        config: Config,
        style: Style,
        localBuilderConfig: BuilderConfig,
        componentFactory: ComponentFactory,
        contentObserver: ContentObserver
    )
}
