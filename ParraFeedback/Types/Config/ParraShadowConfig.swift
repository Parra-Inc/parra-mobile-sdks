//
//  ParraShadowConfig.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 5/22/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import UIKit

public struct ParraShadowConfig {
    public private(set) var color: UIColor
    public private(set) var opacity: Float
    public private(set) var radius: CGFloat
    public private(set) var offset: CGSize
    
    public init(color: UIColor,
                opacity: Float,
                radius: CGFloat,
                offset: CGSize) {
        
        self.color = color
        self.opacity = opacity
        self.radius = radius
        self.offset = offset
    }
    
    public static let `default` = ParraShadowConfig(
        color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.0),
        opacity: 0.0,
        radius: 0.0,
        offset: CGSize(width: 0.0, height: 0.0)
    )

    public static let `defaultDark` = ParraShadowConfig(
        color: UIColor(red: 82.0 / 255.0, green: 82.0 / 255.0, blue: 83.0 / 255.0, alpha: 1.0),
        opacity: 1.0,
        radius: 2.5,
        offset: CGSize(width: 1.0, height: 1.0)
    )

    public static let none = ParraShadowConfig(
        color: .clear,
        opacity: 0.0,
        radius: 0.0,
        offset: .zero
    )
}
