//
//  String+uuid.swift
//  Parra
//
//  Created by Mick MacCallum on 4/17/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension String {
    static var uuid: String {
        return UUID().uuidString
    }
}
