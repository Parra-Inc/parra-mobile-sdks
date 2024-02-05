//
//  Color+AutoAppearance.swift
//  Parra
//
//  Created by Mick MacCallum on 1/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import UIKit
import SwiftUI

internal extension Color {
    init(lightVariant: Color, darkVariant: Color) {
        let uiColor = UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(darkVariant)
            }

            return UIColor(lightVariant)
        }

        self.init(uiColor: uiColor)
    }
}
