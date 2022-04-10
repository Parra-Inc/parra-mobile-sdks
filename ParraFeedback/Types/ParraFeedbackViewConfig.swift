//
//  ParraFeedbackViewConfig.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 3/13/22.
//

import UIKit

@objc(PARParraShadowConfig)
public class ParraShadowConfig: NSObject {
    var color: UIColor
    var opacity: CGFloat
    var radius: CGFloat
    var offset: CGSize
    
    public required init(color: UIColor,
                         opacity: CGFloat,
                         radius: CGFloat,
                         offset: CGSize) {
        
        self.color = color
        self.opacity = opacity
        self.radius = radius
        self.offset = offset

        super.init()
    }
}

@objc(PARParraTextConfig)
public class ParraTextConfig: NSObject {
    let color: UIColor
    let font: UIFont
    let shadow: ParraShadowConfig?

    public required init(color: UIColor,
                         font: UIFont,
                         shadow: ParraShadowConfig?) {
            
        self.color = color
        self.font = font
        self.shadow = shadow
        
        super.init()
    }
}

/// <#Description#>
@objc(PARParraFeedbackViewConfig)
public class ParraFeedbackViewConfig: NSObject {
    var backgroundColor: UIColor
    var tintColor: UIColor
    var cornerRadius: CGFloat = 0.0
    var contentInsets: UIEdgeInsets
    var shadow: ParraShadowConfig
    var title: ParraTextConfig
    var subtitle: ParraTextConfig
    
    public required init(backgroundColor: UIColor,
                         tintColor: UIColor,
                         cornerRadius: CGFloat,
                         contentInsets: UIEdgeInsets,
                         shadow: ParraShadowConfig,
                         title: ParraTextConfig,
                         subtitle: ParraTextConfig) {
        
        self.backgroundColor = backgroundColor
        self.tintColor = tintColor
        self.cornerRadius = cornerRadius
        self.contentInsets = contentInsets
        self.shadow = shadow
        self.title = title
        self.subtitle = subtitle
        
        super.init()
    }

    /// <#Description#>
    @objc(defaultConfiguration)
    public static let `default` = ParraFeedbackViewConfig(
        backgroundColor: UIColor(hex: 0xFAFAFA),
        tintColor: UIColor(hex: 0x200E32),
        cornerRadius: 12,
        contentInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
        shadow: ParraShadowConfig(
            color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.1),
            opacity: 1.0,
            radius: 2.0,
            offset: CGSize(width: 0.0, height: 2.0)
        ),
        title: ParraTextConfig(
            color: .black,
            font: .preferredFont(forTextStyle: .headline),
            shadow: nil
        ),
        subtitle: ParraTextConfig(
            color: .black,
            font: .preferredFont(forTextStyle: .caption2),
            shadow: nil
        )
    )
}
