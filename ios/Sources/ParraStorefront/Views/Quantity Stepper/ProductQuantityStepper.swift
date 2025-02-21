//
//  ProductQuantityStepper.swift
//  Parra
//
//  Created by Mick MacCallum on 10/1/24.
//

import Parra
import SwiftUI

// TODO: Eventually it would be nice if the upper bound provided to
// quantity steppers subtracted the number of units of the product in the cart.

struct ProductQuantityStepper: View {
    // MARK: - Lifecycle

    init(
        value: Binding<UInt>,
        maxQuantity: UInt,
        isLoading: Bool = false,
        allowDeletion: Bool = false
    ) {
        self._value = value
        self.maxQuantity = maxQuantity
        self.isLoading = isLoading
        self.allowDeletion = allowDeletion
    }

    // MARK: - Internal

    @Binding var value: UInt
    let maxQuantity: UInt
    let isLoading: Bool
    let allowDeletion: Bool

    var allowedRange: ClosedRange<UInt> {
        if allowDeletion {
            0 ... maxQuantity
        } else {
            1 ... maxQuantity
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            Button {
                value -= 1
            } label: {
                if allowDeletion && value == 1 {
                    Image(systemName: "trash")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            height: 16
                        )
                        .foregroundStyle(Color(UIColor.darkText))
                } else {
                    Text("－")
                        .foregroundStyle(
                            Color(UIColor.darkText)
                                .opacity(value <= allowedRange.lowerBound ? 0.3 : 0.9)
                        )
                        .font(.system(size: 22))
                }
            }
            .disabled(value <= allowedRange.lowerBound)
            .frame(
                minWidth: 16
            )

            if isLoading {
                ProgressView()
                    .frame(width: 16, height: 16, alignment: .center)
            } else {
                Text(value.formatted())
                    .foregroundStyle(Color(UIColor.darkText))
                    .frame(
                        minWidth: 16
                    )
            }

            Button {
                value += 1
            } label: {
                Text("＋")
                    .foregroundStyle(
                        Color(UIColor.darkText)
                            .opacity(value >= allowedRange.upperBound ? 0.3 : 0.9)
                    )
                    .font(.system(size: 22))
            }
            .disabled(value >= allowedRange.upperBound)
            .frame(
                minWidth: 16
            )
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 16)
        .foregroundColor(.white)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(parraTheme.palette.primary.opacity(0.9))
        }
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var parraTheme
}
