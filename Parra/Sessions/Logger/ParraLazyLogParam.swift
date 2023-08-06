//
//  ParraLazyLogParam.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public enum ParraLazyLogParam {
    case string(() -> String)
    case error(() -> Error)

    internal func produceLog() -> (String, [String : Any]?) {
        switch self {
        case .string(let messageProvider):
            return (messageProvider(), nil)
        case .error(let errorProvider):
            let errorWithExtra = LoggerHelpers.extractMessageAndExtra(
                from: errorProvider()
            )

            return (errorWithExtra.message, errorWithExtra.extra)
        }
    }
}
