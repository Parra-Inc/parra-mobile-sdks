//
//  ParraWidgetConfigurationObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 1/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

fileprivate let logger = Logger(category: "Parra Widget Configuration Observer")

@MainActor
/// Listens for changes to the configured ParraTheme and provides a @Published property ``palette``
/// for SwiftUI views to use to respond to theme changes.
class ParraWidgetConfigurationObserver<WidgetConfiguration: ParraWidgetConfigurationType>: ObservableObject {
    @Published var configuration: WidgetConfiguration

    internal init(
        configuration: WidgetConfiguration
    ) {
        self.configuration = configuration.withDefaultsApplied()
    }
}
