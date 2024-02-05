//
//  View+ConditionalModifiers.swift
//  Parra
//
//  Created by Mick MacCallum on 1/24/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// TODO: Bad practice. Delete these

extension View {
    @ViewBuilder
    func `if`<Content: View>(
        _ predicate: @autoclosure () -> Bool,
        transform: (Self) -> Content
    ) -> some View {
        if predicate() {
            transform(self)
        } else {
            self
        }
    }

    @ViewBuilder func ifNotNil<Content: View, Value>(
        value: Optional<Value>,
        transform: (_ value: Value, _ element: Self) -> Content
    ) -> some View {
        if let value {
            transform(value, self)
        } else {
            self
        }
    }
}
