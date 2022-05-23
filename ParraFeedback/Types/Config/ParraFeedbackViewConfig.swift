//
//  ParraFeedbackViewConfig.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 3/13/22.
//

import UIKit

/// A configuration object for how a `ParraFeedbackView` should look. Use this to customize `ParraFeedbackView`s
/// so that they better blend in with your app's UI.
public struct ParraFeedbackViewConfig {
    public enum Constant {
        public static let defaultBackgroundColor = UIColor(hex: 0xFAFAFA)
        public static let defaultCornerRadius: CGFloat = 12.0
        public static let defaultContentInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }

    var backgroundColor: UIColor
    var tintColor: UIColor?
    var cornerRadius: CGFloat = 0.0
    var contentInsets: UIEdgeInsets
    var shadow: ParraShadowConfig
    var title: ParraTextConfig
    var subtitle: ParraTextConfig
    var body: ParraTextConfig
    
    public init(backgroundColor: UIColor = Constant.defaultBackgroundColor,
                tintColor: UIColor? = nil,
                cornerRadius: CGFloat = Constant.defaultCornerRadius,
                contentInsets: UIEdgeInsets = Constant.defaultContentInsets,
                shadow: ParraShadowConfig = .default,
                title: ParraTextConfig = .titleDefault,
                subtitle: ParraTextConfig = .subtitleDefault,
                body: ParraTextConfig = .bodyDefault) {
        self.backgroundColor = backgroundColor
        self.tintColor = tintColor
        self.cornerRadius = cornerRadius
        self.contentInsets = contentInsets
        self.shadow = shadow
        self.title = title
        self.subtitle = subtitle
        self.body = body
    }

    /// The default configuration used by `ParraFeedbackView`s when no other configuration is provided.
    public static let `default` = ParraFeedbackViewConfig()
}
