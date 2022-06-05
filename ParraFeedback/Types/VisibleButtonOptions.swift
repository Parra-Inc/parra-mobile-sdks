//
//  VisibleButtonOptions.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

internal struct VisibleButtonOptions: OptionSet {
    static let back = VisibleButtonOptions(rawValue: 1)
    static let forward = VisibleButtonOptions(rawValue: 1 << 1)
    
    let rawValue: Int8
}
