//
//  ParraWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 1/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

internal protocol ParraWidget: View {
    associatedtype WidgetConfiguration: ParraWidgetConfigurationType

    var configObserver: ParraWidgetConfigurationObserver<WidgetConfiguration> { get }
    var themeObserver: ParraThemeObserver { get }
}
