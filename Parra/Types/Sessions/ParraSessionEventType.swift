//
//  ParraSessionEventType.swift
//  Parra
//
//  Created by Mick MacCallum on 12/29/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit

public protocol ParraSessionNamedEvent {
    var eventName: String { get }
}

internal enum ParraSessionEventType: ParraSessionNamedEvent {
    private enum Constant {
        // TODO: Should this be like parra:com.actualapp for events from outside the sdk?
        static let corePrefix = "parra"
    }

    // Publicly accessible events
    case action(source: String, module: ParraModule.Type)
    case impression(location: String, module: ParraModule.Type)

    public enum _Internal: ParraSessionNamedEvent {
        case log
        case appState(state: UIApplication.State)

        public var eventName: String {
            switch self {
            case .log:
                return "\(Constant.corePrefix):log"
            case .appState(let state):
                return "\(Constant.corePrefix):appstate:\(state.description)"
            }
        }
    }

    public var eventName: String {
        switch self {
        case .action(let source, let module):
            return "\(module.eventPrefix()):\(source):action"
        case .impression(let location, let module):
            return "\(module.eventPrefix()):\(location):viewed"
        }
    }
}
