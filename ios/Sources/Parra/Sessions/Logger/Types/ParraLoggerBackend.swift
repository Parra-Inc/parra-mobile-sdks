//
//  ParraLoggerBackend.swift
//  Parra
//
//  Created by Mick MacCallum on 7/6/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public protocol ParraLoggerBackend {
    /// bypassEventCreation params are for case for use within Parra SessionStorage infrastructure,
    /// in places where writing console logs can not safely generate events due to recursion risks.

    func log(data: ParraLogData)
    func logMultiple(data: [ParraLogData])
}
