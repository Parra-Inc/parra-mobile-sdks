//
//  ParraShadowConfig.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 5/22/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import UIKit

public struct ParraShadowConfig {
    var color: UIColor
    var opacity: Float
    var radius: CGFloat
    var offset: CGSize
    
    public init(color: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1),
                opacity: Float = 1.0,
                radius: CGFloat = 2.0,
                offset: CGSize = CGSize(width: 0.0, height: 2.0)) {
        
        self.color = color
        self.opacity = opacity
        self.radius = radius
        self.offset = offset
    }
    
    public static let `default` = ParraShadowConfig()
}
