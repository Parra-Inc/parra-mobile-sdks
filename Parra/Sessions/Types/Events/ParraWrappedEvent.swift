//
//  ParraWrappedEvent.swift
//  Parra
//
//  Created by Mick MacCallum on 7/22/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal enum ParraWrappedEvent {
    case event(
        event: ParraEvent,
        extra: [String: Any]? = nil
    )

    case dataEvent(
        event: ParraDataEvent,
        extra: [String: Any]? = nil
    )

    case internalEvent(
        event: ParraInternalEvent,
        extra: [String: Any]? = nil
    )
}
