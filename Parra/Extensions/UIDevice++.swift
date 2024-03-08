//
//  UIDevice++.swift
//  Parra
//
//  Created by Mick MacCallum on 3/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import UIKit

extension UIDevice {
    static let isTablet = UIDevice.current.userInterfaceIdiom == .pad
    static let isIpad = isTablet
}
