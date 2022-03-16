//
//  ParraFeedbackViewConfig.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 3/13/22.
//

import UIKit


/// <#Description#>
public struct ParraFeedbackViewConfig {
    var backgroundColor: UIColor
    var tintColor: UIColor
    var cornerRadius: CGFloat
    var contentInsets: UIEdgeInsets
    var shadowColor: UIColor
    var shadowOpacity: CGFloat
    var shadowRadius: CGFloat
    var shadowSize: CGSize
    
    /// <#Description#>
    public static let `default` = ParraFeedbackViewConfig(
        backgroundColor: UIColor(hex: 0xFAFAFA),
        tintColor: UIColor(hex: 0x200E32),
        cornerRadius: 12,
        contentInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
        shadowColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.1),
        shadowOpacity: 1.0,
        shadowRadius: 2.0,
        shadowSize: .init(width: 0.0, height: 2.0)
    )
}
