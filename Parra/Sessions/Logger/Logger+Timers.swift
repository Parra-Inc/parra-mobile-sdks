//
//  Logger+Timers.swift
//  Parra
//
//  Created by Mick MacCallum on 7/6/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public extension Logger {
    // TODO: It is possible that multiple markers returned from `time()` functions could be chained together to measure
    //       the times between multiple events. It would be nice to detect that a start marker was itself a measurement
    //       against its own start marker and output in a format that allowed you to see the entire sequence of measurements.

    /// Measures the time since the start marker was created and then prints a message indicating how long the action took.
    ///
    /// - Parameters:
    ///   - startMarker: The marker that is being measured against.
    ///   - message: A custom message that you want to provide to be displayed before the between now and the `startMarker`.
    ///              If no message is provided, we will use the message that was attached to the log that created the
    ///              `startMarker`.
    ///   - format: The format that the duration since the `startMarker` should be displayed in. Options include:
    ///             * `seconds` (e.x. "70 seconds"
    ///             * `pretty` (e.x. "1 minute, 10 seconds)
    ///             * `custom` This option allows you to pass a `DateComponentsFormatter`, giving you complete control
    ///                          over the output format.
    ///             If an error is encountered formatting the output, we fall back on the `seconds` style.
    /// - Returns: A ``ParraLogMarkerMeasurement`` containing data about the measurement, that can be useful if you want
    ///            to record any of this information in your own systems. This return value is discardable.
    @discardableResult
    static func measureTime(
        since startMarker: ParraLogMarker,
        message: String? = nil,
        format: ParraLogMeasurementFormat = .pretty,
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) -> ParraLogMarkerMeasurement {
        let endDate = Date.now // Should be the very first line.
        let threadInfo = ParraLoggerThreadInfo(
            thread: .current
        )

        let callSiteContext = ParraLoggerCallSiteContext(
            fileId: fileId,
            function: function,
            line: line,
            column: column,
            threadInfo: threadInfo
        )

        let timeInterval = endDate.timeIntervalSince(startMarker.timestamp)

        // If the user provided a custom message, use it. Otherwise use the message that was attached to the
        // start marker
        let messageProvider = createMessage(
            for: message ?? startMarker.message.produceLog().0,
            with: timeInterval,
            in: format
        )

        let lazyMessage = ParraLazyLogParam.string(messageProvider)

        // Context is tricky here, because there is a case where a marker created by a logger instance with
        // more context is passed to the static time measurement method, which lacks the same context.

        let nextMarker = logToBackend(
            level: .info,
            message: lazyMessage,
            callSiteContext: callSiteContext
        )

        return ParraLogMarkerMeasurement(
            timeInterval: timeInterval,
            nextMarker: nextMarker
        )
    }

    /// Measures the time since the start marker was created and then prints a message indicating how long the action took.
    ///
    /// - Parameters:
    ///   - startMarker: The marker that is being measured against.
    ///   - message: A custom message that you want to provide to be displayed before the between now and the `startMarker`.
    ///              If no message is provided, we will use the message that was attached to the log that created the
    ///              `startMarker`.
    ///   - format: The format that the duration since the `startMarker` should be displayed in. Options include:
    ///             * `seconds` (e.x. "70 seconds"
    ///             * `pretty` (e.x. "1 minute, 10 seconds)
    ///             * `custom` This option allows you to pass a `DateComponentsFormatter`, giving you complete control
    ///                          over the output format.
    ///             If an error is encountered formatting the output, we fall back on the `seconds` style.
    /// - Returns: A ``ParraLogMarkerMeasurement`` containing data about the measurement, that can be useful if you want
    ///            to record any of this information in your own systems. This return value is discardable.
    @discardableResult
    func measureTime(
        since startMarker: ParraLogMarker,
        message: String? = nil,
        format: ParraLogMeasurementFormat = .pretty,
        _ fileId: String = #fileID,
        _ function: String = #function,
        _ line: Int = #line,
        _ column: Int = #column
    ) -> ParraLogMarkerMeasurement {
        let endDate = Date.now
        let threadInfo = ParraLoggerThreadInfo(
            thread: .current
        )

        let callSiteContext = ParraLoggerCallSiteContext(
            fileId: fileId,
            function: function,
            line: line,
            column: column,
            threadInfo: threadInfo
        )

        let timeInterval = endDate.timeIntervalSince(startMarker.timestamp)

        // If the user provided a custom message, use it. Otherwise use the message that was attached to the
        // start marker
        let messageProvider = Logger.createMessage(
            for: message ?? startMarker.message.produceLog().0,
            with: timeInterval,
            in: format
        )

        let lazyMessage = ParraLazyLogParam.string(messageProvider)
        let nextMarker = logToBackend(
            level: .info,
            message: lazyMessage,
            callSiteContext: callSiteContext
        )

        return ParraLogMarkerMeasurement(
            timeInterval: timeInterval,
            nextMarker: nextMarker
        )
    }

    private static func createMessage(
        for eventName: String,
        with timeInterval: TimeInterval,
        in format: ParraLogMeasurementFormat
    ) -> String {
        if timeInterval < 60 {
            let formatted = timeInterval
                .formatted(.number.precision(.fractionLength(4)))
            return "\(formatted) second(s)"
        }

        var formatter = Parra.InternalConstants.Formatters
            .dateComponentsFormatter

        formatter.formattingContext = .middleOfSentence
        formatter.includesApproximationPhrase = false
        formatter.unitsStyle = .full
        formatter.allowsFractionalUnits = true

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
}
