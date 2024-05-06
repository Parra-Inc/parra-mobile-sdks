//
//  ParraTypography.swift
//  Parra
//
//  Created by Mick MacCallum on 1/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public enum ParraTextStyle {
    case largeTitle
    case title
    case title2
    case title3
    case headline
    case subheadline
    case body
    case callout
    case caption
    case caption2
    case footnote

    // MARK: - Lifecycle

    init(
        _ systemTextStyle: Font.TextStyle
    ) {
        switch systemTextStyle {
        case .largeTitle:
            self = .largeTitle
        case .title:
            self = .title
        case .title2:
            self = .title2
        case .title3:
            self = .title3
        case .headline:
            self = .headline
        case .subheadline:
            self = .subheadline
        case .body:
            self = .body
        case .callout:
            self = .callout
        case .caption:
            self = .caption
        case .caption2:
            self = .caption2
        case .footnote:
            self = .footnote
        default:
            self = .body
        }
    }

    // MARK: - Internal

    var systemTextStyle: Font.TextStyle {
        switch self {
        case .largeTitle:
            return .largeTitle
        case .title:
            return .title
        case .title2:
            return .title2
        case .title3:
            return .title3
        case .headline:
            return .headline
        case .subheadline:
            return .subheadline
        case .body:
            return .body
        case .callout:
            return .callout
        case .caption:
            return .caption
        case .caption2:
            return .caption2
        case .footnote:
            return .footnote
        }
    }
}

public struct ParraTypography {
    // MARK: - Public

    public static let `default` = ParraTypography(
        textStyles: [:]
    )

    // MARK: - Internal

    let textStyles: [ParraTextStyle: ParraAttributes.Text]

    func getTextAttributes(
        for fontStyle: ParraTextStyle
    ) -> ParraAttributes.Text? {
        return textStyles[fontStyle]
    }
}
