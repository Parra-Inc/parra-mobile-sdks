//
//  ParraLoggerStackSymbols.swift
//  Parra
//
//  Created by Mick MacCallum on 9/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public enum ParraLoggerStackSymbols: Codable {
    case raw([String])
    case demangled([CallStackFrame])
    case none

    // MARK: - Internal

    var frameStrings: [String] {
        switch self {
        case .none:
            return []
        case .raw(let frames):
            return frames
        case .demangled(let frames):
            return frames.map { frame in
                return "\(frame.frameNumber)\t\(frame.binaryName)\t\(frame.address)\t\(frame.symbol) + \(frame.byteOffset)"
            }
        }
    }
}
