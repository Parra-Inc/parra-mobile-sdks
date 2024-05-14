//
//  ParraAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 5/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

/// All defaults should be nil and rely on defaults defined in the view
/// after accessing the theme/etc from env.
public enum ParraAttributes {
    public typealias Badge = ParraAttributes.Label
}

protocol OverridableAttributes {
    func mergingOverrides(_ overrides: Self?) -> Self
}

protocol ParraCommonViewAttributes {
    var border: ParraAttributes.Border { get }
    var cornerRadius: ParraCornerRadiusSize? { get }
    var padding: ParraPaddingSize? { get }
    var background: Color? { get }
}
