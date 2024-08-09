//
//  ParraChangelogWidgetConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 3/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public class ParraChangelogWidgetConfig: ContainerConfig {
    // MARK: - Lifecycle

    public required init() {}

    // MARK: - Public

    public static let `default` = ParraChangelogWidgetConfig()
}

// public static let `default` = ChangelogWidgetConfig(
//    title: LabelConfig(fontStyle: .title),
//    releasePreviewNames: LabelConfig(fontStyle: .headline),
//    releasePreviewDescriptions: LabelConfig(fontStyle: .body),
//    releasePreviewCreatedAts: LabelConfig(fontStyle: .caption),
//    releaseDetailTitle: LabelConfig(fontStyle: .title),
//    releaseDetailSubtitle: LabelConfig(fontStyle: .subheadline),
//    releaseDetailDescription: LabelConfig(fontStyle: .body),
//    releaseDetailSectionTitle: LabelConfig(fontStyle: .title2),
//    releaseDetailSectionItem: LabelConfig(fontStyle: .body),
//    releaseDetailShowOtherReleasesButton: ,
//    emptyStateView: .default,
//    errorStateView: .errorDefault
// )
