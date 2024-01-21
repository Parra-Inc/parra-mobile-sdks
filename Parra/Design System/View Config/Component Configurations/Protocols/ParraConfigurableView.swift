//
//  ParraConfigurableView.swift
//  Parra
//
//  Created by Mick MacCallum on 1/22/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// Parra configurable components are:
// 1. Intended to have their interfaces exposed publically
// 2. Receive input via params and output (optionally) via event handlers.
// 3. Are dumb and do not transform any data on input/output

/// Configurable views accept view configs
internal protocol ParraConfigurableView: View {
    associatedtype ViewConfigType: ParraViewConfigType

    var viewConfig: ViewConfigType { get }
}
