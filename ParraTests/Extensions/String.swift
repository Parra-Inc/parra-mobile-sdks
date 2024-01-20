//
//  String.swift
//  ParraTests
//
//  Created by Mick MacCallum on 7/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension String {
    static var now: String {
        return Date().ISO8601Format()
    }
}
