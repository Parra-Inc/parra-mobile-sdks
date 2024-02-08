//
//  ParraSessionEventContext.swift
//  Parra
//
//  Created by Mick MacCallum on 9/10/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

struct ParraSessionEventContext {
    /// The event was generated from outside of the Parra SDK.
    let isClientGenerated: Bool

    /// An indication to the session storage module about the priority of this event
    /// with regards to syncs. Used to make sure that low priority events that happen
    /// during syncs are not used to trigger new syncs.
    let syncPriority: ParraSessionEventSyncPriority
}
