//
//  Container.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

internal protocol Container: View {
    associatedtype Factory: ParraComponentFactory
    associatedtype Config: ContainerConfig
    associatedtype ContentObserver: ContainerContentObserver

    /// Should be one of:
    /// 1. ``Parra.ScreenStyle``
    /// 2. ``Parra.ToastStyle``
    /// 3. ``Parra.WidgetStyle``
    associatedtype Style: ContainerStyle

    var config: Config { get }
    var componentFactory: ComponentFactory<Factory> { get }
    
    var contentObserver: ContentObserver { get }
    var themeObserver: ParraThemeObserver { get }
}
