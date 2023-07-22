//
//  ParraLoggerBackend.swift
//  Parra
//
//  Created by Mick MacCallum on 7/6/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public protocol ParraLoggerBackend {
    func log(data: ParraLogData)
    func logMultiple(data: [ParraLogData])
}
