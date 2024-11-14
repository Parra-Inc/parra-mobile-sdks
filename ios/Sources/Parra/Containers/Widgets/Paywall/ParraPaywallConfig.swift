//
//  ParraPaywallConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 11/12/24.
//

import SwiftUI

public final class ParraPaywallConfig: ParraContainerConfig {
    // MARK: - Lifecycle

    public init(
        defaultTitle: String = "Premium Membership",
        defaultSubtitle: String =
            "Start a subscription to our premium membership to access this premium content.",
        defaultImage: UIImage = UIImage(systemName: "sparkles")!
    ) {
        self.defaultTitle = defaultTitle
        self.defaultSubtitle = defaultSubtitle
        self.defaultImage = defaultImage
    }

    // MARK: - Public

    public static let `default` = ParraPaywallConfig()

    public let defaultTitle: String
    public let defaultSubtitle: String
    public let defaultImage: UIImage
}
