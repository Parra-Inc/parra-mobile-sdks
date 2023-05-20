//
//  ParraCardViewConfig.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 3/13/22.
//

import UIKit
import ParraCore

internal protocol ParraConfigurableCardView {
    func applyConfig(_ config: ParraCardViewConfig)
}

/// A configuration object for how a `ParraCardView` should look. Use this to customize `ParraCardView`s
/// so that they better blend in with your app's UI.
public struct ParraCardViewConfig {
    public enum Constant {
        public static let defaultBackgroundColor = UIColor(hex: 0xFAFAFA)
        public static let defaultBackgroundColorDark = UIColor(hex: 0x27252C)
        public static let defaultCornerRadius: CGFloat = 12.0
        public static let defaultContentInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        public static let defaultTintColor = Parra.Constant.brandColor
        public static let defaultAccessoryTintColor = UIColor(hex: 0x5BC0DE)
        public static let defaultAccessoryDisabledTintColor = UIColor(hex: 0xe3e4e6)
    }
    
    public private(set) var backgroundColor: UIColor
    public private(set) var tintColor: UIColor?
    public private(set) var accessoryTintColor: UIColor?
    public private(set) var accessoryDisabledTintColor: UIColor?
    public private(set) var cornerRadius: CGFloat = 0.0
    public private(set) var contentInsets: UIEdgeInsets
    public private(set) var shadow: ParraShadowConfig
    public private(set) var title: ParraTextConfig
    public private(set) var subtitle: ParraTextConfig
    public private(set) var body: ParraTextConfig
    public private(set) var bodyBold: ParraTextConfig
    public private(set) var label: ParraTextConfig

    public init(backgroundColor: UIColor = Constant.defaultBackgroundColor,
                tintColor: UIColor? = Constant.defaultTintColor,
                accessoryTintColor: UIColor? = Constant.defaultAccessoryTintColor,
                accessoryDisabledTintColor: UIColor? = Constant.defaultAccessoryDisabledTintColor,
                cornerRadius: CGFloat = Constant.defaultCornerRadius,
                contentInsets: UIEdgeInsets = Constant.defaultContentInsets,
                shadow: ParraShadowConfig = .default,
                title: ParraTextConfig = .titleDefault,
                subtitle: ParraTextConfig = .subtitleDefault,
                body: ParraTextConfig = .bodyDefault,
                bodyBold: ParraTextConfig = .bodyDefaultBold,
                label: ParraTextConfig = .labelDefault
    ) {
        self.backgroundColor                = backgroundColor
        self.tintColor                      = tintColor
        self.accessoryTintColor             = accessoryTintColor
        self.accessoryDisabledTintColor     = accessoryDisabledTintColor
        self.cornerRadius                   = cornerRadius
        self.contentInsets                  = contentInsets
        self.shadow                         = shadow
        self.title                          = title
        self.subtitle                       = subtitle
        self.body                           = body
        self.bodyBold                       = bodyBold
        self.label                          = label
    }
    
    /// The default configuration used by `ParraCardView`s when no other configuration is provided.
    public static let `default` = ParraCardViewConfig()

    public static let defaultDark = ParraCardViewConfig(
        backgroundColor: Constant.defaultBackgroundColorDark,
        shadow: .defaultDark,
        title: .titleDefaultDark,
        subtitle: .subtitleDefaultDark,
        body: .bodyDefaultDark,
        bodyBold: .bodyDefaultDark
    )

    public static let drawerDefault = ParraCardViewConfig(shadow: .none)

    public static let drawerDefaultDark = ParraCardViewConfig(
        backgroundColor: Constant.defaultBackgroundColorDark,
        shadow: .none,
        title: .titleDefaultDark,
        subtitle: .subtitleDefaultDark,
        body: .bodyDefaultDark,
        bodyBold: .bodyDefaultDark
    )
}
