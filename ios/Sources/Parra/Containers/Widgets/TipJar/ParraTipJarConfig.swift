//
//  ParraTipJarConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 11/15/24.
//

import SwiftUI
import UIKit

public final class ParraTipJarConfig: ParraContainerConfig {
    // MARK: - Lifecycle

    public init(
        defaultTitle: String = "Leave a Tip",
        defaultSubtitle: String =
            "Your donations help us keep the lights on and the content flowing.",
        defaultImage: UIImage? = UIImage(systemName: "heart")
    ) {
        self.defaultTitle = defaultTitle
        self.defaultSubtitle = defaultSubtitle
        self.defaultImage = defaultImage
    }

    // MARK: - Public

    public static let `default` = ParraTipJarConfig()

    public let defaultTitle: String
    public let defaultSubtitle: String
    public let defaultImage: UIImage?
}
