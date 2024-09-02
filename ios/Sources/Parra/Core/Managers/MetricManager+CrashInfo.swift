//
//  MetricManager+CrashInfo.swift
//  Parra
//
//  Created by Mick MacCallum on 7/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import MetricKit

extension MetricManager {
    struct CrashInfo: Codable, Hashable, ParraSanitizedDictionaryConvertible {
        // MARK: - Lifecycle

        init(
            crash: MXCrashDiagnostic,
            endDate: Date
        ) {
            self.createdAt = endDate
            self.code = crash.exceptionCode?.intValue
            self.type = crash.exceptionType?.intValue
            self.reason = ExceptionReason(
                exceptionReason: crash.exceptionReason
            )
            self.signal = crash.signal?.intValue
            self.terminationReason = crash.terminationReason
            self.virtualMemoryRegionInfo = crash.virtualMemoryRegionInfo
            self.callstackJson = String(
                data: crash.callStackTree.jsonRepresentation(),
                encoding: .utf8
            )
        }

        // MARK: - Internal

        struct ExceptionReason: Codable, Hashable, ParraSanitizedDictionaryConvertible {
            // MARK: - Lifecycle

            init?(
                exceptionReason: MXCrashDiagnosticObjectiveCExceptionReason?
            ) {
                guard let exceptionReason else {
                    return nil
                }

                self.composedMessage = exceptionReason.composedMessage
                self.formatString = exceptionReason.formatString
                self.arguments = exceptionReason.arguments
                self.exceptionType = exceptionReason.exceptionType
                self.className = exceptionReason.className
                self.exceptionName = exceptionReason.exceptionName
            }

            // MARK: - Internal

            let composedMessage: String
            let formatString: String
            let arguments: [String]
            let exceptionType: String
            let className: String
            let exceptionName: String

            var sanitized: ParraSanitizedDictionary {
                return [
                    "composed_message": composedMessage,
                    "format_string": formatString,
                    "arguments": arguments,
                    "exception_type": exceptionType,
                    "class_name": className,
                    "exception_name": exceptionName
                ]
            }
        }

        let createdAt: Date
        let code: Int?
        let type: Int?
        let reason: ExceptionReason?
        let signal: Int?
        let terminationReason: String?
        let virtualMemoryRegionInfo: String?
        let callstackJson: String?

        var sanitized: ParraSanitizedDictionary {
            return [
                "code": code,
                "type": type,
                "reason": reason?.sanitized,
                "signal": signal,
                "termination_reason": terminationReason,
                "virtual_memory_region_info": virtualMemoryRegionInfo,
                "callstack_json": callstackJson
            ]
        }
    }
}
