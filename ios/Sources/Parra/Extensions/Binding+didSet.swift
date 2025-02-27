//
//  Binding+didSet.swift
//  Parra
//
//  Created by Mick MacCallum on 2/20/25.
//

import SwiftUI

extension Binding {
    func didSet(
        _ didSet: @escaping (Value) -> Void
    ) -> Binding<Value> {
        return Binding(
            get: {
                return wrappedValue
            },
            set: { newValue in
                wrappedValue = newValue

                didSet(newValue)
            }
        )
    }
}
