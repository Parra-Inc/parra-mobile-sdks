//
//  ParraImageContent.swift
//  Parra
//
//  Created by Mick MacCallum on 2/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public enum ParraImageContent: Hashable, Equatable {
    /// Assets libraries
    case resource(String, Bundle? = .main, Image.TemplateRenderingMode? = nil)

    /// Name of image in app bundle
    case name(String, Bundle? = .main, Image.TemplateRenderingMode? = nil)

    /// SFSymbol name
    case symbol(String, SymbolRenderingMode? = nil)

    /// Raw UIImage
    case image(UIImage, Image.TemplateRenderingMode? = nil)

    // MARK: - Public

    public static func == (
        lhs: ParraImageContent,
        rhs: ParraImageContent
    ) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .resource(let string, let bundle, let templateRenderingMode):
            hasher.combine("resource")
            hasher.combine(string)
            hasher.combine(bundle)
            hasher.combine(templateRenderingMode)
        case .name(let string, let bundle, let templateRenderingMode):
            hasher.combine("name")
            hasher.combine(string)
            hasher.combine(bundle)
            hasher.combine(templateRenderingMode)
        case .symbol(let string, let symbolRenderingMode):
            hasher.combine("symbol")
            hasher.combine(string)
            hasher.combine(symbolRenderingMode.debugDescription)
        case .image(let uIImage, let templateRenderingMode):
            hasher.combine("image")
            hasher.combine(uIImage)
            hasher.combine(templateRenderingMode)
        }
    }
}
