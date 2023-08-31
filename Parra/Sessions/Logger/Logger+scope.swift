//
//  Logger+scope.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public extension Logger {

    /// <#Description#>
    /// - Parameters:
    ///   - name: <#name description#>
    func scope(
        named name: String? = nil,
        _ function: String = #function
    ) -> Logger {
        return scope(named: name, extra: [:], function)
    }

    /// - Parameters:
    ///   - name: <#name description#>
    ///   - extra: <#extra description#>
    func scope(
        named name: String? = nil,
        extra: [String : Any],
        _ function: String = #function
    ) -> Logger {
        let subCategories: [String]
        if let name {
            subCategories = [name, function]
        } else {
            subCategories = [function]
        }

        return Logger(
            parent: self,
            context: context.addingSubcategories(
                subcategories: subCategories,
                extra: extra
            ),
            bypassEventCreation: bypassEventCreation
        )
    }

    ///
    /// <#Description#>
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - extra: <#extra description#>
    ///   - block: <#block description#>
    func withScope(
        named name: String? = nil,
        block: (_ logger: Logger) throws -> Void,
        _ function: String = #function
    ) rethrows {
        try withScope(
            named: name,
            extra: [:],
            block: block,
            function
        )
    }

    /// - Parameters:
    ///   - name: <#name description#>
    ///   - extra: <#extra description#>
    ///   - block: <#block description#>
    func withScope(
        named name: String? = nil,
        extra: [String : Any],
        block: (_ logger: Logger) throws -> Void,
        _ function: String = #function
    ) rethrows {
        let scoped = scope(named: name, extra: extra, function)

        do {
            try block(scoped)
        } catch let error {
            scoped.error(error)
            throw error
        }
    }
    
    // TODO: static variants of these. All should also support returning from their blocks.
}
