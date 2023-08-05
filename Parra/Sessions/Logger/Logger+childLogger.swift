//
//  Logger+childLogger.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public extension Logger {
    // TODO: Call this child or scope?
    func childLogger(subcategory: String, extra: [String : Any] = [:]) -> Logger {
        return Logger(
            parent: self,
            context: context.addingSubcategory(
                subcategory: subcategory,
                extra: extra
            )
        )
    }
}
