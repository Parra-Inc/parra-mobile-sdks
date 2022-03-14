//
//  UIFont+Extensions.swift
//  Parra Core
//
//  Created by Michael MacCallum on 12/31/21.
//

import UIKit

extension UIFont {
    static var fontsRegistered = false

    static func registerFontsIfNeeded() {
        if fontsRegistered {
            return
        }
        
        let bundle = Bundle(for: Parra.self)
        guard let fontUrls = bundle.urls(forResourcesWithExtension: "ttf", subdirectory: nil) else {
            return
        }
        
        fontUrls.forEach {
            CTFontManagerRegisterFontsForURL($0 as CFURL, .process, nil)
        }
        
        fontsRegistered = true
    }
}
