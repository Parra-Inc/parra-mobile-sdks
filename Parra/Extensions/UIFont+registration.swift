//
//  UIFont+Extensions.swift
//  Parra
//
//  Created by Michael MacCallum on 12/31/21.
//

import UIKit
import os

extension UIFont {
    private static let fontRegisteredLock = OSAllocatedUnfairLock(initialState: false)

    static func registerFontsIfNeeded() {
        fontRegisteredLock.withLock { hasRegistered in
            if hasRegistered {
                return
            }

            let bundle = Bundle(for: Parra.self)
            guard let fontUrls = bundle.urls(forResourcesWithExtension: "ttf", subdirectory: nil) else {
                return
            }

            fontUrls.forEach {
                CTFontManagerRegisterFontsForURL($0 as CFURL, .process, nil)
            }

            hasRegistered = true
        }
    }
}
