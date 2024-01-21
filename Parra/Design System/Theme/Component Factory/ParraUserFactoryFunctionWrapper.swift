//
//  ParraUserFactoryFunctionWrapper.swift
//  Parra
//
//  Created by Mick MacCallum on 1/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

internal protocol ParraUserFactoryFunctionWrapperType {}

internal struct ParraUserFactoryFunctionWrapper<T: ParraViewConfigType>: ParraUserFactoryFunctionWrapperType {
    let type: T.Type
    let function: (_ config: T) -> any View
}
