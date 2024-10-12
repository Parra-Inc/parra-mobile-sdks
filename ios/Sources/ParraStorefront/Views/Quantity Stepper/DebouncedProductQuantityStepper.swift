//
//  DebouncedProductQuantityStepper.swift
//  KbIosApp
//
//  Created by Mick MacCallum on 10/3/24.
//

import Combine
import SwiftUI

struct DebouncedProductQuantityStepper: View {
    // MARK: - Lifecycle

    init(
        value: Binding<UInt>,
        maxQuantity: UInt,
        debounceDelay: TimeInterval = 3.0,
        allowDeletion: Bool = false
    ) {
        self._value = value
        self.maxQuantity = maxQuantity
        self.debounceDelay = debounceDelay
        self.allowDeletion = allowDeletion
        self._localValue = State(initialValue: value.wrappedValue)
    }

    // MARK: - Internal

    @Binding var value: UInt
    let maxQuantity: UInt
    let debounceDelay: TimeInterval
    let allowDeletion: Bool

    var body: some View {
        ProductQuantityStepper(
            value: $localValue,
            maxQuantity: maxQuantity,
            allowDeletion: allowDeletion
        )
        .onChange(of: localValue) { _, newValue in
            isDebouncing = true

            debounceSubject.send(newValue)
        }
        .onAppear {
            debounceSubscription = debounceSubject
                .debounce(
                    for: .seconds(debounceDelay),
                    scheduler: DispatchQueue.main
                )
                .sink { debouncedValue in
                    value = debouncedValue

                    isDebouncing = false
                }
        }
        .onDisappear {
            debounceSubscription?.cancel()
        }
    }

    // MARK: - Private

    @State private var localValue: UInt
    @State private var debounceSubject = PassthroughSubject<UInt, Never>()
    @State private var debounceSubscription: AnyCancellable?
    @State private var isDebouncing: Bool = false
}
