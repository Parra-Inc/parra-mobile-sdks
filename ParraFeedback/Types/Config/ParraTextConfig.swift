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
        color: .init(red: 51, green: 51, blue: 51),
        font: .systemFont(ofSize: 18, weight: .medium),
        shadow: .default
    )
    
    public static let subtitleDefault = ParraTextConfig(
        color: .black.withAlphaComponent(0.87),
        font: .systemFont(ofSize: 12, weight: .light),
        shadow: .default
    )
    
    public static let bodyDefault = ParraTextConfig(
        color: .black,
        font: .preferredFont(forTextStyle: .title3),
        shadow: .default
    )

    public static let bodyBold = ParraTextConfig(
        color: .black,
        font: .systemFont(ofSize: 13, weight: .bold),
        shadow: .default
    )

    public static let titleDefaultDark = ParraTextConfig(
        color: .white,
        font: .systemFont(ofSize: 18, weight: .medium),
        shadow: .default
    )
    
    public static let subtitleDefaultDark = ParraTextConfig(
        color: UIColor(hex: 0x9C9BA4),
        font: .systemFont(ofSize: 12, weight: .light),
        shadow: .default
    )
    
    public static let bodyDefaultDark = ParraTextConfig(
        color: UIColor(hex: 0x9C9BA4),
        font: .preferredFont(forTextStyle: .title3),
        shadow: .default
    )

    public static let bodyBoldDark = ParraTextConfig(
        color: UIColor(hex: 0x9C9BA4),
        font: .systemFont(ofSize: 13, weight: .bold),
        shadow: .default
    )
}
