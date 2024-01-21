//
//  ParraWidgetConfigurationType.swift
//  Parra
//
//  Created by Mick MacCallum on 1/22/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

internal protocol ParraWidgetConfigurationType {
    static var `default`: Self { get }

    func withDefaultsApplied() -> Self
}
