//
//  ParraLoggerContext.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

// TODO: How should we handle the case where someone creates a new logger and passes a category
// name that is the exact same as the file name/class name?

public struct ParraLoggerContext {
    public let module: String
    public let fileName: String
    public let categories: [String]
    public let extra: [String : Any]

    internal init(
        fileId: String,
        categories: [String],
        extra: [String : Any]
    ) {
        let (module, fileName, _) = LoggerHelpers.splitFileId(
            fileId: fileId
        )

        self.module = module
        self.fileName = fileName
        self.categories = categories
        self.extra = extra
    }

    internal init(
        module: String,
        fileName: String,
        categories: [String],
        extra: [String : Any]
    ) {
        self.module = module
        self.fileName = fileName
        self.categories = categories
        self.extra = extra
    }

    internal func addingSubcategories(
        subcategories: [String],
        extra: [String : Any]? = nil
    ) -> ParraLoggerContext {
        let mergedExtra: [String : Any]
        if let extra {
            mergedExtra = self.extra.merging(extra) { $1 }
        } else {
            mergedExtra = self.extra
        }

        return ParraLoggerContext(
            module: module,
            fileName: fileName,
            categories: categories + subcategories,
            extra: mergedExtra
        )
    }
}
