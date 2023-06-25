//
//  ParraWrappedLogMessage.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public enum ParraWrappedLogMessage {
    case string(() -> String)
    case error(() -> Error)
}
