//
//  Date+fromIso8601String.swift
//  Parra
//
//  Created by Mick MacCallum on 3/25/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension Date {
    static func fromIso8601String(
        _ dateString: String,
        formatter: ISO8601DateFormatter =
            ParraInternal.Constants.Formatters.iso8601Formatter
    ) -> Date? {
        guard let date = formatter.date(from: dateString) else {
            return nil
        }

        return date
    }
}
