//
//  ParraStandardEvent.swift
//  Parra
//
//  Created by Mick MacCallum on 6/25/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public enum ParraStandardEvent: ParraDataEvent {
    case action(source: String)
    case close(screen: String)
    case custom(name: String, extra: [String: Any])
    case open(screen: String)
    case purchase(product: String)
    case start(span: String)
    case stop(span: String)
    case submit(form: String)
    case tap(element: String)
    case view(element: String)

    // MARK: Lifecycle

    public init(name: String, extra: [String: Any]) {
        let components = name.split(separator: ":")
        if components.count != 2 {
            self = .custom(name: name, extra: extra)
            return
        }

        let nameKey = String(components[0])
        let value = String(components[1])
        switch nameKey {
        case "action":
            self = .action(source: value)
        case "close":
            self = .close(screen: value)
        case "custom":
            self = .custom(name: value, extra: extra)
        case "open":
            self = .open(screen: value)
        case "purchase":
            self = .purchase(product: value)
        case "start":
            self = .start(span: value)
        case "stop":
            self = .stop(span: value)
        case "submit":
            self = .submit(form: value)
        case "tap":
            self = .tap(element: value)
        case "view":
            self = .view(element: value)
        default:
            self = .custom(
                name: value,
                extra: extra
            )
        }
    }

    // MARK: Public

    public var name: String {
        switch self {
        case .action(let source):
            return "action:\(source)"
        case .close(let screen):
            return "close:\(screen)"
        case .custom(let name, _):
            return "custom:\(name)"
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

    public var extra: [String: Any] {
        switch self {
        case .custom(_, let extra):
            return extra
        default:
            return [:]
        }
    }
}
