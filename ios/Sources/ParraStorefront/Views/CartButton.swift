//
//  CartButton.swift
//  Parra
//
//  Created by Mick MacCallum on 9/30/24.
//

import Parra
import ShopifyCheckoutSheetKit
import SwiftUI

private let logger = ParraLogger()

struct CartButton: View {
    // MARK: - Internal

    @Binding var cartState: StorefrontWidget.ContentObserver.CartState

    var body: some View {
        switch cartState {
        case .ready(let readyStateInfo):
            let quantity = readyStateInfo.quantity

            NavigationLink(
                value: "cart"
            ) {
                Image(systemName: "cart")
            }
            .padding(.trailing, 10)
            .padding(.top, 4)
            .transition(.symbolEffect(.automatic))
            .animation(.easeInOut, value: quantity)
            .overlay(alignment: .topTrailing) {
                if quantity < 1 {
                    EmptyView()
                } else {
                    let overflow = quantity > 9

                    Text(overflow ? "9+" : String(quantity))
                        .font(.callout)
                        .fontDesign(.monospaced)
                        .contrastingForegroundColor(
                            to: parraTheme.palette.primary.toParraColor(),
                            darkColor: parraTheme.lightPalette.primaryText
                                .toParraColor(),
                            lightColor: parraTheme.darkPalette?.primaryText
                                .toParraColor() ?? .white
                        )
                        .foregroundStyle(
                            parraTheme.palette.primaryText.toParraColor()
                        )
                        .padding(.vertical, 1.5)
                        .padding(.horizontal, 6)
                        .background(
                            parraTheme.palette.primary.toParraColor()
                        )
                        .clipShape(.capsule)
                        .allowsHitTesting(false)
                        .offset(x: overflow ? 11 : 0, y: -2)
                        .transition(.symbolEffect(.automatic))
                        .symbolEffect(.pulse, value: quantity)
                }
            }
        case .loading, .error, .checkoutComplete, .checkoutFailed:
            EmptyView()
        }
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var parraTheme
}
