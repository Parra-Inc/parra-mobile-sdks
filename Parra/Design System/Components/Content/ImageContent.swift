//
//  ImageContent.swift
//  Parra
//
//  Created by Mick MacCallum on 2/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public enum ImageContent {
    /// Assets libraries
    case resource(String, Image.TemplateRenderingMode? = nil)

    /// Name of image in app bundle
    case name(String, Bundle?, Image.TemplateRenderingMode? = nil)

    /// SFSymbol name
    case symbol(String, SymbolRenderingMode? = nil)

    /// Raw UIImage
    case image(UIImage, Image.TemplateRenderingMode? = nil)
}
