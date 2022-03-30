//
//  ParraFeedbackViewConfig.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 3/13/22.
//

import UIKit

public struct ParraShadowConfig {
    var color: UIColor
    var opacity: CGFloat
    var radius: CGFloat
    var offset: CGSize
}

public struct ParraTextConfig {
    let color: UIColor
    let font: UIFont
    let shadow: ParraShadowConfig?
}

/// <#Description#>
public struct ParraFeedbackViewConfig {
    var backgroundColor: UIColor
    var tintColor: UIColor
    var cornerRadius: CGFloat
    var contentInsets: UIEdgeInsets
    var shadow: ParraShadowConfig
    var title: ParraTextConfig
    var subtitle: ParraTextConfig

    /// <#Description#>
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
