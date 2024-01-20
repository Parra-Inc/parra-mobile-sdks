//
//  ParraLogMeasurementFormat.swift
//  Parra
//
//  Created by Mick MacCallum on 7/6/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public enum ParraLogMeasurementFormat {
    case seconds
    case pretty
    case custom(DateComponentsFormatter)
}
