//
//  Int.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 3/25/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension Int {
    func simplePluralized(singularString: String) -> String {
        if self == 1 {
            return singularString
        }

        return "\(singularString)s"
    }
}
