//
//  ParraStandardEvent.swift
//  Parra
//
//  Created by Mick MacCallum on 6/25/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public enum ParraStandardEvent: ParraEvent {
    case action(source: String)
    case close(screen: String)
    case open(screen: String)
    case purchase(product: String)
    case start(span: String)
    case stop(span: String)
    case submit(form: String)
    case tap(element: String)
    case view(element: String)

    public var name: String {
        switch self {
        case .action(let source):
            return "action:\(source)"
        case .close(let screen):
            return "close:\(screen)"
        case .open(let screen):
            return "open:\(screen)"
        case .purchase(let product):
            return "purchase:\(product)"
        case .start(let span):
            return "start:\(span)"
        case .stop(let span):
            return "stop:\(span)"
        case .submit(let form):
            return "submit:\(form)"
        case .tap(let element):
            return "tap:\(element)"
        case .view(let element):
            return "view:\(element)"
        }
    }

    public var params: [String : Any] {
        return [:]
    }
}
