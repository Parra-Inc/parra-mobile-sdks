//
//  ParraModuleStateAccessor.swift
//  Parra
//
//  Created by Mick MacCallum on 7/2/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal protocol ParraModuleStateAccessor {
    var state: ParraState { get }
    var configState: ParraConfigState { get }
}
