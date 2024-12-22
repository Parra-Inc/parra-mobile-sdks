//
//  ParraFixture.swift
//  Parra
//
//  Created by Mick MacCallum on 1/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import SwiftUI

/// Model objects should conform to this type and implement its methods to define high quality fixtures
/// which can be used in the context of multiple SwiftUI views.
public protocol ParraFixture {
    static func validStates() -> [Self]
    static func invalidStates() -> [Self]
}

extension ParraFixture {
    static func invalidStates() -> [Self] {
        return []
    }
}

public extension ParraFixture {
    @ViewBuilder
    static func renderValidStates(
        with handler: @escaping (Self) -> some View
    ) -> some View {
        renderStates(
            states: validStates(),
            with: handler
        )
    }

    @ViewBuilder
    static func renderInvalidStates(
        with handler: @escaping (Self) -> some View
    ) -> some View {
        renderStates(
            states: invalidStates(),
            with: handler
        )
    }

    @ViewBuilder
    static func renderStates(
        states: [Self],
        with handler: @escaping (Self) -> some View
    ) -> some View {
        VStack {
            // Iterate by index and lookup elements. Saves requirement for
            // conforming types to also implement Identifiable.
            ForEach(states.indices, id: \.self) { index in
                handler(states[index])
            }
        }
    }
}
