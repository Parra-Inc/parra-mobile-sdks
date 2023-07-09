//
//  ParraSessionParamDictionaryConvertible.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal protocol ParraSessionParamDictionaryConvertible {
    var paramDictionary: [String: Any] { get }
}
