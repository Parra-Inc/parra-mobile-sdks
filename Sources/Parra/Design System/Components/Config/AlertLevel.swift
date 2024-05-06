//
//  AlertLevel.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public enum AlertLevel: CaseIterable {
    case success
    case info
    case warn
    case error
}

//
// public struct : Equatable {
//    // MARK: - Lifecycle
//
//    public init(
//        level: Level = .info
//    ) {
//        self.level = level
//    }
//
//    // MARK: - Public
//
////    public static let `default` = AlertConfig(
////        style: .info,
////        title: LabelConfig(fontStyle: .headline),
////        subtitle: LabelConfig(fontStyle: .subheadline),
////        dismiss: ImageButtonConfig(
////            style: .secondary,
////            size: .custom(defaultDismissButtonSize),
////            variant: .plain
////        )
////    )
//
////    public static let defaultWhatsNew = AlertConfig(
////        style: .info,
////        title: LabelConfig(fontStyle: .headline),
////        subtitle: LabelConfig(fontStyle: .subheadline),
////        dismiss: ImageButtonConfig(
////            style: .secondary,
////            size: .custom(defaultDismissButtonSize),
////            variant: .plain
////        )
////    )
//
//    public let level: Level
//
//    // MARK: - Internal
//
////    static let defaultDismissButtonSize = CGSize(width: 12, height: 12)
// }
