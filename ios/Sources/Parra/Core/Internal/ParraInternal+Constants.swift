//
//  ParraInternal+Constants.swift
//  Parra
//
//  Created by Mick MacCallum on 3/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension ParraInternal {
    internal enum Demo {
        /// The Parra sample app's workspace ID. You should not use this.
        /// Instead, grab your workspace ID from
        /// https://parra.io/dashboard/settings
        static let workspaceId = "201cbcf0-b5d6-4079-9e4d-177ae04cc9f4"

        /// The Parra sample app's application ID. You should not use this.
        /// Instead, grab your application ID from
        /// https://parra.io/dashboard/applications
        static let applicationId = "edec3a6c-a375-4a9d-bce8-eb00860ef228"
    }

    enum Constants {
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

        static let parraApiHost = "parra.io"
        static let parraApiRoot =
            URL(string: "https://api.\(parraApiHost)/v1/")!
        static let backgroundTaskName = "com.parra.session.backgroundtask"
        static let backgroundTaskDuration: TimeInterval = 25.0
        static let betaAppBundleId = "com.parra.parra-ios-client"
        static let eventPrefix = "parra:"
    }
}
