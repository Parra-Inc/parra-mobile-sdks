//
//  ParraSessionEventType.swift
//  ParraCore
//
//  Created by Mick MacCallum on 12/29/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

public protocol ParraSessionNamedEvent {
    var eventName: String { get }
}

public enum ParraSessionEventType: ParraSessionNamedEvent {
    private enum Constant {
        static let corePrefix = Parra.eventPrefix()
    }

    // Publicly accessible events
    case impression(location: String, module: ParraModule.Type)

    public enum _Internal: ParraSessionNamedEvent {
        case log

        public var eventName: String {
            switch self {
            case .log:
                return "\(Constant.corePrefix):log"
            }
        }
    }

    public var eventName: String {
        switch self {
        case .impression(let location, let module):
            return "\(module.eventPrefix()):\(location):viewed"
        }
    }
}
