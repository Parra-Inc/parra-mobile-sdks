//
//  ProductQuantityStepper.swift
//  Parra
//
//  Created by Mick MacCallum on 10/1/24.
//

import SwiftUI

public struct ParraStepper: View {
    // MARK: - Lifecycle

    public init(
        value: Binding<Int>,
        minQuantity: Int? = 1,
        maxQuantity: Int? = .max,
        isLoading: Bool = false
    ) {
        self._value = value
        self.minQuantity = minQuantity ?? 1
        self.maxQuantity = maxQuantity ?? .max
        self.isLoading = isLoading
    }

    // MARK: - Public

    public var body: some View {
        HStack(spacing: 8) {
            Button {
                value -= 1
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
                Text(value.formatted())
                    .foregroundStyle(Color(UIColor.darkText))
                    .frame(
                        minWidth: 16
                    )
                    .layoutPriority(15)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            Button {
                value += 1
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
                    parraTheme.palette.primary.shade400.opacity(0.4)
                )
        }
    }

    // MARK: - Internal

    @Binding var value: Int
    let minQuantity: Int
    let maxQuantity: Int
    let isLoading: Bool

    var allowedRange: ClosedRange<Int> {
        minQuantity ... maxQuantity
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var parraTheme
}
