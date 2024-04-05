//
//  ParraConfigurationOptionType.swift
//  Parra
//
//  Created by Mick MacCallum on 3/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public protocol ParraConfigurationOptionType {
    static var `default`: Self { get }
}
