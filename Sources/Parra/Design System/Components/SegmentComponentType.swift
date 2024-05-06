//
//  SegmentComponentType.swift
//  Parra
//
//  Created by Mick MacCallum on 2/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

protocol SegmentComponentType: View {
    var config: SegmentConfig { get }
    var content: SegmentContent { get }
    var style: ParraAttributedSegmentStyle { get }

    init(
        config: SegmentConfig,
        content: SegmentContent,
        style: ParraAttributedSegmentStyle
    )
}
