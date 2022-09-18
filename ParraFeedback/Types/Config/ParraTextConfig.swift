//
//  ParraTextConfig.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 5/22/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import UIKit

public struct ParraTextConfig {
    public let color: UIColor
    public let font: UIFont
    public let shadow: ParraShadowConfig
    
    public init(color: UIColor = .black,
                font: UIFont = .preferredFont(forTextStyle: .headline),
                shadow: ParraShadowConfig = .default) {
        
        self.color = color
        self.font = font
        self.shadow = shadow
    }
    
    public static let titleDefault = ParraTextConfig(
        color: .black,
        font: .preferredFont(forTextStyle: .headline),
        shadow: .default
    )
    
    public static let subtitleDefault = ParraTextConfig(
        color: .black,
        font: .preferredFont(forTextStyle: .caption2),
        shadow: .default
    )
    
    public static let bodyDefault = ParraTextConfig(
        color: .black,
        font: .preferredFont(forTextStyle: .title3),
        shadow: .default
    )
    
    public static let titleDefaultDark = ParraTextConfig(
        color: .white,
        font: .preferredFont(forTextStyle: .headline),
        shadow: .default
    )
    
    public static let subtitleDefaultDark = ParraTextConfig(
        color: UIColor(hex: 0x9C9BA4),
        font: .preferredFont(forTextStyle: .caption2),
        shadow: .default
    )
    
    public static let bodyDefaultDark = ParraTextConfig(
        color: UIColor(hex: 0x9C9BA4),
        font: .preferredFont(forTextStyle: .title3),
        shadow: .default
    )
}
