//
//  ParraEvent.swift
//  Parra
//
//  Created by Mick MacCallum on 6/25/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

/// <#Description#>
public protocol ParraEvent {
    /// A unique name for the event. Event names should be all lowercase and in_snake_case.
    var name: String { get }

    /// Any additional data that you would like to attach to the event. Useful for filtering and
    /// viewing additional context about users producing the event in the dashboard.
    var params: [String: Any] { get }
}
