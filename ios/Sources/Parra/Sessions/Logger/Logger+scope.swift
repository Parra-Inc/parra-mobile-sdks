//
//  Logger+scope.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public extension ParraLogger {
    /// Creates a new scope with the provided name but does not immediately enter it. This scope can be used
    /// to group multiple logs relevant to a given action. You can also automatically encapsulate a block of code
    /// within a scope by using ``Logger/withScope(named:_:_:)-29mab``
    func scope(
        named name: String? = nil,
        _ function: String = #function
    ) -> ParraLogger {
        // TODO: Maybe capture call site info here and use it to add scope entered/exited logs
        return scope(named: name, nil, function)
    }

    /// Creates a new scope with the provided name but does not immediately enter it. This scope can be used
    /// to group multiple logs relevant to a given action. You can also automatically encapsulate a block of code
    /// within a scope by using ``Logger/withScope(named:_:_:)-29mab``
    func scope(
        named name: String? = nil,
        _ extra: [String: Any]?,
        _ function: String = #function
    ) -> ParraLogger {
        let scopes: [ParraLoggerScopeType] = if let name {
            [.customName(name), .function(function)]
        } else {
            [.function(function)]
        }

        return Logger(
            parent: self,
            context: context.addingScopes(
                scopes: scopes,
                extra: extra
            )
        )
    }

    /// Creates a new scope for the logger with the provided `name`. This scope will be entered before executing
    /// the `block` function and will exit once the execution of `block` has completed. Any errors thrown
    /// as a result of executing `block` are automatically logged and rethrown. The value returned by `block`
    /// will be returned from the `withScope` function.
    func withScope<T>(
        named name: String? = nil,
        _ block: (_ logger: ParraLogger) -> T,
        _ function: String = #function
    ) -> T {
        return withScope(named: name, nil, block, function)
    }

    /// Creates a new scope for the logger with the provided `name`. This scope will be entered before executing
    /// the `block` function and will exit once the execution of `block` has completed. Any errors thrown
    /// as a result of executing `block` are automatically logged and rethrown. The value returned by `block`
    /// will be returned from the `withScope` function.
    func withScope<T>(
        named name: String? = nil,
        _ extra: [String: Any]?,
        _ block: (_ logger: ParraLogger) -> T,
        _ function: String = #function
    ) -> T {
        let scoped = scope(named: name, extra, function)

        return block(scoped)
    }

    /// Creates a new scope for the logger with the provided `name`. This scope will be entered before executing
    /// the `block` function and will exit once the execution of `block` has completed. Any errors thrown
    /// as a result of executing `block` are automatically logged and rethrown. The value returned by `block`
    /// will be returned from the `withScope` function.
    func withScope<T>(
        named name: String? = nil,
        _ block: (_ logger: ParraLogger) throws -> T,
        _ function: String = #function
    ) throws -> T {
        return try withScope(named: name, nil, block, function)
    }

    /// Creates a new scope for the logger with the provided `name`. This scope will be entered before executing
    /// the `block` function and will exit once the execution of `block` has completed. Any errors thrown
    /// as a result of executing `block` are automatically logged and rethrown. The value returned by `block`
    /// will be returned from the `withScope` function.
    func withScope<T>(
        named name: String? = nil,
        _ extra: [String: Any]?,
        _ block: (_ logger: ParraLogger) throws -> T,
        _ function: String = #function
    ) rethrows -> T {
        let scoped = scope(named: name, extra, function)

        do {
            return try block(scoped)
        } catch {
            scoped.error(error)
            throw error
        }
    }

    /// Creates a new scope for the logger with the provided `name`. This scope will be entered before executing
    /// the `block` function and will exit once the execution of `block` has completed. Any errors thrown
    /// as a result of executing `block` are automatically logged and rethrown. The value returned by `block`
    /// will be returned from the `withScope` function.
    func withScope<T>(
        named name: String? = nil,
        _ block: (_ logger: ParraLogger) async throws -> T,
        _ function: String = #function
    ) async throws -> T {
        return try await withScope(named: name, nil, block, function)
    }

    /// Creates a new scope for the logger with the provided `name`. This scope will be entered before executing
    /// the `block` function and will exit once the execution of `block` has completed. Any errors thrown
    /// as a result of executing `block` are automatically logged and rethrown. The value returned by `block`
    /// will be returned from the `withScope` function.
    func withScope<T>(
        named name: String? = nil,
        _ extra: [String: Any]?,
        _ block: (_ logger: ParraLogger) async throws -> T,
        _ function: String = #function
    ) async rethrows -> T {
        let scoped = scope(named: name, extra, function)

        do {
            return try await block(scoped)
        } catch {
            scoped.error(error)
            throw error
        }
    }

    /// Creates a new scope for the logger with the provided `name`. This scope will be entered before executing
    /// the `block` function and will exit once the execution of `block` has completed. Any errors thrown
    /// as a result of executing `block` are automatically logged and rethrown. The value returned by `block`
    /// will be returned from the `withScope` function.
    func withScope<T>(
        named name: String? = nil,
        _ block: (_ logger: ParraLogger) async -> T,
        _ function: String = #function
    ) async -> T {
        return await withScope(named: name, nil, block, function)
    }

    /// Creates a new scope for the logger with the provided `name`. This scope will be entered before executing
    /// the `block` function and will exit once the execution of `block` has completed. Any errors thrown
    /// as a result of executing `block` are automatically logged and rethrown. The value returned by `block`
    /// will be returned from the `withScope` function.
    func withScope<T>(
        named name: String? = nil,
        _ extra: [String: Any]?,
        _ block: (_ logger: ParraLogger) async -> T,
        _ function: String = #function
    ) async -> T {
        let scoped = scope(named: name, extra, function)

        return await block(scoped)
    }

    /// Creates a new scope with the provided name but does not immediately enter it. This scope can be used
    /// to group multiple logs relevant to a given action. You can also automatically encapsulate a block of code
    /// within a scope by using ``Logger/withScope(named:_:_:)-29mab``
    static func scope(
        named name: String? = nil,
        _ function: String = #function
    ) -> ParraLogger {
        // TODO: Maybe capture call site info here and use it to add scope entered/exited logs
        return scope(named: name, nil, function)
    }

    /// Creates a new scope with the provided name but does not immediately enter it. This scope can be used
    /// to group multiple logs relevant to a given action. You can also automatically encapsulate a block of code
    /// within a scope by using ``Logger/withScope(named:_:_:)-29mab``
    static func scope(
        named name: String? = nil,
        _ extra: [String: Any]?,
        _ function: String = #function
    ) -> ParraLogger {
        return ParraLogger(category: name, extra: extra)
            .scope(named: nil, function)
    }

    /// Creates a new scope for the logger with the provided `name`. This scope will be entered before executing
    /// the `block` function and will exit once the execution of `block` has completed. Any errors thrown
    /// as a result of executing `block` are automatically logged and rethrown. The value returned by `block`
    /// will be returned from the `withScope` function.
    static func withScope<T>(
        named name: String? = nil,
        _ block: (_ logger: ParraLogger) -> T,
        _ function: String = #function
    ) -> T {
        return withScope(named: name, nil, block, function)
    }

    /// Creates a new scope for the logger with the provided `name`. This scope will be entered before executing
    /// the `block` function and will exit once the execution of `block` has completed. Any errors thrown
    /// as a result of executing `block` are automatically logged and rethrown. The value returned by `block`
    /// will be returned from the `withScope` function.
    static func withScope<T>(
        named name: String? = nil,
        _ extra: [String: Any]?,
        _ block: (_ logger: ParraLogger) -> T,
        _ function: String = #function
    ) -> T {
        let scoped = scope(named: name, extra, function)

        return block(scoped)
    }

    /// Creates a new scope for the logger with the provided `name`. This scope will be entered before executing
    /// the `block` function and will exit once the execution of `block` has completed. Any errors thrown
    /// as a result of executing `block` are automatically logged and rethrown. The value returned by `block`
    /// will be returned from the `withScope` function.
    static func withScope<T>(
        named name: String? = nil,
        _ block: (_ logger: ParraLogger) throws -> T,
        _ function: String = #function
    ) throws -> T {
        return try withScope(named: name, nil, block, function)
    }

    /// Creates a new scope for the logger with the provided `name`. This scope will be entered before executing
    /// the `block` function and will exit once the execution of `block` has completed. Any errors thrown
    /// as a result of executing `block` are automatically logged and rethrown. The value returned by `block`
    /// will be returned from the `withScope` function.
    static func withScope<T>(
        named name: String? = nil,
        _ extra: [String: Any]?,
        _ block: (_ logger: ParraLogger) throws -> T,
        _ function: String = #function
    ) rethrows -> T {
        let scoped = scope(named: name, extra, function)

        do {
            return try block(scoped)
        } catch {
            scoped.error(error)
            throw error
        }
    }

    /// Creates a new scope for the logger with the provided `name`. This scope will be entered before executing
    /// the `block` function and will exit once the execution of `block` has completed. Any errors thrown
    /// as a result of executing `block` are automatically logged and rethrown. The value returned by `block`
    /// will be returned from the `withScope` function.
    static func withScope<T>(
        named name: String? = nil,
        _ block: (_ logger: ParraLogger) async throws -> T,
        _ function: String = #function
    ) async throws -> T {
        return try await withScope(named: name, nil, block, function)
    }

    /// Creates a new scope for the logger with the provided `name`. This scope will be entered before executing
    /// the `block` function and will exit once the execution of `block` has completed. Any errors thrown
    /// as a result of executing `block` are automatically logged and rethrown. The value returned by `block`
    /// will be returned from the `withScope` function.
    static func withScope<T>(
        named name: String? = nil,
        _ extra: [String: Any]?,
        _ block: (_ logger: ParraLogger) async throws -> T,
        _ function: String = #function
    ) async rethrows -> T {
        let scoped = scope(named: name, extra, function)

        do {
            return try await block(scoped)
        } catch {
            scoped.error(error)
            throw error
        }
    }

    /// Creates a new scope for the logger with the provided `name`. This scope will be entered before executing
    /// the `block` function and will exit once the execution of `block` has completed. Any errors thrown
    /// as a result of executing `block` are automatically logged and rethrown. The value returned by `block`
    /// will be returned from the `withScope` function.
    static func withScope<T>(
        named name: String? = nil,
        _ block: (_ logger: ParraLogger) async -> T,
        _ function: String = #function
    ) async -> T {
        return await withScope(named: name, nil, block, function)
    }

    /// Creates a new scope for the logger with the provided `name`. This scope will be entered before executing
    /// the `block` function and will exit once the execution of `block` has completed. Any errors thrown
    /// as a result of executing `block` are automatically logged and rethrown. The value returned by `block`
    /// will be returned from the `withScope` function.
    static func withScope<T>(
        named name: String? = nil,
        _ extra: [String: Any]?,
        _ block: (_ logger: ParraLogger) async -> T,
        _ function: String = #function
    ) async -> T {
        let scoped = scope(named: name, extra, function)

        return await block(scoped)
    }
}
