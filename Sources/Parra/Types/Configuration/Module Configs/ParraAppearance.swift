//
//  ParraAppearance.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public enum ParraAppearance: Equatable, CaseIterable, Identifiable,
    CustomStringConvertible
{
    case light
    case dark
    case system

    // MARK: - Public

    public var id: String {
        switch self {
        case .light:
            return "light"
        case .dark:
            return "dark"
        case .system:
            return "system"
        }
    }

    public var description: String {
        switch self {
        case .light:
            return "Always light"
        case .dark:
            return "Always dark"
        case .system:
            return "Follow system settings"
        }
    }

    // MARK: - Internal

    var colorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return .none
        }
    }
}
