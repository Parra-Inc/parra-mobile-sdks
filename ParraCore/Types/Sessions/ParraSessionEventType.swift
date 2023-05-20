//
//  ParraSessionEventType.swift
//  ParraCore
//
//  Created by Mick MacCallum on 12/29/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit

public protocol ParraSessionNamedEvent {
    var eventName: String { get }
}

public enum ParraSessionEventType: ParraSessionNamedEvent {
    private enum Constant {
        static let corePrefix = Parra.eventPrefix()
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
