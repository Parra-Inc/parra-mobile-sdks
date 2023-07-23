//
//  ParraLoggerContext+ParraDictionaryConvertible.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension ParraLoggerContext: ParraDictionaryConvertible {
    public var dictionary: [String: Any] {
        return [
            "module": module,
            "file_name": fileName,
            "categories": categories,
            "extra": extra
        ]
    }
}
