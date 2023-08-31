//
//  Logger+scope.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

// TODO: These can probably be de-duplicated if the non-throwing variants wrap a call to the throwing variant in a do/catch and just log the error without rethrowing

public extension Logger {

    /// <#Description#>
    /// - Parameters:
    ///   - name: <#name description#>
    func scope(
        named name: String? = nil,
        _ function: String = #function
    ) -> Logger {
        // TODO: Maybe capture call site info here and use it to add scope entered/exited logs
        return scope(named: name, extra: nil, function)
    }

    /// <#Description#>
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - extra: <#extra description#>
    func scope(
        named name: String? = nil,
        extra: [String : Any]?,
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

    /// <#Description#>
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - extra: <#extra description#>
    ///   - block: <#block description#>
    func withScope<T>(
        named name: String? = nil,
        block: (_ logger: Logger) -> T,
        _ function: String = #function
    ) -> T {
        return withScope(
            named: name,
            extra: nil,
            block: block,
            function
        )
    }

    /// <#Description#>
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - extra: <#extra description#>
    ///   - block: <#block description#>
    func withScope<T>(
        named name: String? = nil,
        extra: [String : Any]?,
        block: (_ logger: Logger) -> T,
        _ function: String = #function
    ) -> T {
        let scoped = scope(named: name, extra: extra, function)

        return block(scoped)
    }

    /// <#Description#>
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - extra: <#extra description#>
    ///   - block: <#block description#>
    func withScope<T>(
        named name: String? = nil,
        block: (_ logger: Logger) throws -> T,
        _ function: String = #function
    ) throws -> T {
        return try withScope(
            named: name,
            extra: nil,
            block: block,
            function
        )
    }

    /// <#Description#>
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - extra: <#extra description#>
    ///   - block: <#block description#>
    func withScope<T>(
        named name: String? = nil,
        extra: [String : Any]?,
        block: (_ logger: Logger) throws -> T,
        _ function: String = #function
    ) rethrows -> T {
        let scoped = scope(named: name, extra: extra, function)

        do {
            return try block(scoped)
        } catch let error {
            scoped.error(error)
            throw error
        }
    }

    /// <#Description#>
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - extra: <#extra description#>
    ///   - block: <#block description#>
    func withScope<T>(
        named name: String? = nil,
        block: (_ logger: Logger) async throws -> T,
        _ function: String = #function
    ) async throws -> T {
        return try await withScope(
            named: name,
            extra: nil,
            block: block,
            function
        )
    }

    /// <#Description#>
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - extra: <#extra description#>
    ///   - block: <#block description#>
    func withScope<T>(
        named name: String? = nil,
        extra: [String : Any]?,
        block: (_ logger: Logger) async throws -> T,
        _ function: String = #function
    ) async rethrows -> T {
        let scoped = scope(named: name, extra: extra, function)

        do {
            return try await block(scoped)
        } catch let error {
            scoped.error(error)
            throw error
        }
    }

    /// <#Description#>
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - extra: <#extra description#>
    ///   - block: <#block description#>
    func withScope<T>(
        named name: String? = nil,
        block: (_ logger: Logger) async -> T,
        _ function: String = #function
    ) async -> T {
        return await withScope(
            named: name,
            extra: nil,
            block: block,
            function
        )
    }

    /// <#Description#>
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - extra: <#extra description#>
    ///   - block: <#block description#>
    func withScope<T>(
        named name: String? = nil,
        extra: [String : Any]?,
        block: (_ logger: Logger) async -> T,
        _ function: String = #function
    ) async -> T {
        let scoped = scope(named: name, extra: extra, function)

        return await block(scoped)
    }

    // TODO: static variants of these. All should also support returning from their blocks.
}
