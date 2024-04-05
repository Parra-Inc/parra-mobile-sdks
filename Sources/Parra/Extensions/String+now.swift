//
//  String+now.swift
//  Parra
//
//  Created by Mick MacCallum on 4/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension String {
    static var now: String {
        return Date().ISO8601Format()
    }
}
