//
//  ParraAttributedStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 2/4/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

internal protocol ParraAttributedStyle {
    associatedtype Attributes

    var attributes: Attributes { get }
}
