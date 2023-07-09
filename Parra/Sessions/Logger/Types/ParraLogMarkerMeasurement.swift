//
//  ParraLogMarkerMeasurement.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraLogMarkerMeasurement {
    /// The time that has passed since the start marker was created.
    let timeInterval: TimeInterval

    /// A new marker representing the current point in time. Pass this to
    /// a subsequent call to ``Logger/measureTime(since:eventName:format:callSiteContext:_:)``
    let nextMarker: ParraLogMarker
}
