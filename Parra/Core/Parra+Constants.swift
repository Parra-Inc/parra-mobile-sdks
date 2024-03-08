//
//  Parra+Constants.swift
//  Parra
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation
import UIKit

public extension Parra {
    enum Constants {
        // MARK: - Public facing constants

        /// A key that cooresponds to a unique sync token provided with sync begin/ending notifications.
        public static let syncTokenKey = "syncToken"

        public static let brandColor = UIColor(
            red: 232.0 / 255.0,
            green: 68.0 / 255.0,
            blue: 71.0 / 255.0,
            alpha: 1.0
        )

        public static let parraWebRoot = URL(string: "https://parra.io/")!
    }

    internal enum InternalConstants {
        enum Formatters {
            /// Important! The exact settings of this formatter are critical for
            /// decoding dates send from the Parra API. The default iso8601
            /// formatter does not handle fractional seconds.
            static let iso8601Formatter: ISO8601DateFormatter = {
                // Format of dates from server: 2024-02-24T20:47:51.530Z

                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [
                    .withInternetDateTime,
                    .withFractionalSeconds
                ]

                return formatter
            }()

            static let dateComponentsFormatter = DateComponentsFormatter()
            static let dateIntervalFormatter = DateIntervalFormatter()

            static let dateFormatter: DateFormatter = {
                let formatter = DateFormatter()

                formatter.locale = .current
                formatter.timeZone = .current

                return formatter
            }()

            static let rfc3339DateFormatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                formatter.timeZone = TimeZone(secondsFromGMT: 0)

                return formatter
            }()
        }

        static let parraApiRoot = URL(string: "https://api.parra.io/v1/")!
        static let backgroundTaskName = "com.parra.session.backgroundtask"
        static let backgroundTaskDuration: TimeInterval = 25.0
    }
}
