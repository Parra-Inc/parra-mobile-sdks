//
//  ParraMergableViewConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 1/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public protocol ParraMergableViewConfig {
    func mergedConfig(with replacementConfig: Self?) -> Self
}
