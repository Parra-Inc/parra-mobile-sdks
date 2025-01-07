//
//  ProductQuantityStepper.swift
//  Parra
//
//  Created by Mick MacCallum on 10/1/24.
//

import SwiftUI

public struct ParraStepper<T: Strideable>: View {
    // MARK: - Lifecycle

    public init(
        value: Binding<T>,
        minQuantity: T,
        maxQuantity: T,
        step: T.Stride,
        isLoading: Bool = false
    ) {
        self._value = value
        self.minQuantity = minQuantity
        self.maxQuantity = maxQuantity
        self.step = step
        self.isLoading = isLoading
    }

    // MARK: - Public

    public var body: some View {
        HStack(spacing: 8) {
            Button {
                value = value.advanced(by: -step)
            } label: {
                Text("－")
                    .foregroundStyle(
                        Color(UIColor.darkGray)
                            .opacity(value <= allowedRange.lowerBound ? 0.3 : 1)
                    )
                    .font(.system(size: 22))
            }
            .disabled(value <= allowedRange.lowerBound)
            .frame(
                minWidth: 16
            )

            if isLoading {
                ProgressView()
                    .frame(width: 16, height: 16, alignment: .center)
            } else {
                Text("\(value)")
                    .foregroundStyle(Color(UIColor.darkText))
                    .font(.caption)
                    .fontDesign(.monospaced)
                    .frame(
                        width: 28
                    )
                    .layoutPriority(15)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            Button {
                value = value.advanced(by: step)
            } label: {
                Text("＋")
                    .foregroundStyle(
                        Color(UIColor.darkGray)
                            .opacity(value >= allowedRange.upperBound ? 0.3 : 1)
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
                .fill(
                    parraTheme.palette.primary.opacity(0.25)
                )
        }
    }

    // MARK: - Internal

    @Binding var value: T
    let minQuantity: T
    let maxQuantity: T
    let step: T.Stride
    let isLoading: Bool

    var allowedRange: ClosedRange<T> {
        minQuantity ... maxQuantity
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var parraTheme
}
