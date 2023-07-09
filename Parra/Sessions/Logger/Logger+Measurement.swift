//
//  Logger+Measurement.swift
//  Parra
//
//  Created by Mick MacCallum on 7/6/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public extension Logger {
    // TODO: Measuring the time since a marker should automatically be considered a "moment"

    @discardableResult
    static func measureTime(
        since startMarker: ParraLogMarker,
        eventName: String,
        format: ParraLogMeasurementFormat,
        callSiteContext: ParraLoggerCallSiteContext = (
            fileId: #fileID,
            function: #function,
            line: #line,
            column: #column
        ),
        _ threadInfo: ParraLoggerThreadInfo = ParraLoggerThreadInfo(
            thread: .current
        )
    ) -> ParraLogMarkerMeasurement {
        let endMarker = ParraLogMarker(
            context: startMarker.context,
            startingContext: callSiteContext
        )
        let timeInterval = endMarker.date.timeIntervalSince(startMarker.date)

        let createMessage = { () -> String in
            var formatter = Parra.InternalConstants.Formatters.dateComponentsFormatter

            formatter.formattingContext = .middleOfSentence
            formatter.includesApproximationPhrase = false
            formatter.unitsStyle = .full

            switch format {
            case .seconds:
                formatter.allowedUnits = [.second]
            case .pretty:
                formatter.allowedUnits = [.second, .minute, .hour]
                formatter.collapsesLargestUnit = true
            case .custom(let customFormatter):
                formatter = customFormatter
            }

            let formattedInterval = formatter.string(
                from: timeInterval
            ) ?? "\(timeInterval) second(s)"

            return "\(eventName) took \(formattedInterval)"
        }

        let nextMarker = logToBackend(
            level: .info,
            message: .string(createMessage),
            context: startMarker.context,
            callSiteContext: callSiteContext,
            threadInfo: threadInfo
        )

        return ParraLogMarkerMeasurement(
            timeInterval: timeInterval,
            nextMarker: nextMarker
        )
    }
}
