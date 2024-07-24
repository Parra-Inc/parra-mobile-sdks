//
//  ParraLoggerContext.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

/// A context object representative of the logger and the state that it's in at the
/// time when a log is created.
struct ParraLoggerContext {
    // MARK: - Lifecycle

    init(
        fiberId: String?,
        fileId: String,
        category: String?,
        scope: ParraLoggerScopeType,
        extra: [String: Any]?
    ) {
        let (module, fileName, fileExtension) = LoggerHelpers.splitFileId(
            fileId: fileId
        )

        let scopes: [ParraLoggerScopeType] = if case .function(let rawName) =
            scope, rawName == module
        {
            // If a function scope is present, and it has the same name as the module
            // it means the logger instance was created at top level in a file, and
            // this function scope is garbage data.
            []
        } else {
            [scope]
        }

        self.fiberId = fiberId
        self.module = module
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.category = category
        self.scopes = scopes
        self.extra = extra
    }

    init(
        fiberId: String?,
        fileId: String,
        category: String?,
        scopes: [ParraLoggerScopeType],
        extra: [String: Any]?
    ) {
        let (module, fileName, fileExtension) = LoggerHelpers.splitFileId(
            fileId: fileId
        )

        self.fiberId = fiberId
        self.module = module
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.category = category
        self.scopes = scopes
        self.extra = extra
    }

    init(
        fiberId: String?,
        module: String,
        fileName: String,
        fileExtension: String?,
        category: String?,
        scopes: [ParraLoggerScopeType],
        extra: [String: Any]?
    ) {
        self.fiberId = fiberId
        self.module = module
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.category = category
        self.scopes = scopes
        self.extra = extra
    }

    // MARK: - Internal

    let fiberId: String?

    // Context items in order of precedence
    let module: String
    let fileName: String
    let fileExtension: String?

    // This is the name provided when creating a logger instance. It will be the name of the class/etc
    // that a logger is an instance variable of, in cases where we auto-create them. Some cases, like
    // static logger methods, will not have a category defined.
    let category: String?

    // Think of scopes as subcategories, which allow for arbitrary nesting
    let scopes: [ParraLoggerScopeType]

    let extra: [String: Any]?

    func addingScopes(
        scopes newScopes: [ParraLoggerScopeType],
        extra newExtra: [String: Any]? = nil
    ) -> ParraLoggerContext {
        let mergedExtra: [String: Any]? = if let newExtra {
            if let extra {
                extra.merging(newExtra) { $1 }
            } else {
                newExtra
            }
        } else {
            extra
        }

        var mergedScopes = [ParraLoggerScopeType]()

        let mergeIfNotDuplicate = { (scope: ParraLoggerScopeType) in
            if !scopes.contains(scope) {
                mergedScopes.append(scope)
            }
        }

        for scope in newScopes {
            switch scope {
            case .customName(let customScopeName):
                // If the scope has a custom name, we have a special case to deduplicate it with the file
                // name. There is a high probability that top level loggers will be given names that
                // exactly match the name of the file.
                if customScopeName != fileName {
                    mergeIfNotDuplicate(scope)
                }
            case .function:
                // If it's a function name, it can be added to the scopes list, as long as it isn't a
                // duplicate.
                mergeIfNotDuplicate(scope)
            }
        }

        return ParraLoggerContext(
            fiberId: fiberId,
            module: module,
            fileName: fileName,
            fileExtension: fileExtension,
            category: category,
            scopes: mergedScopes,
            extra: mergedExtra
        )
    }
}
