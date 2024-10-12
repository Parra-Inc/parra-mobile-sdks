//
//  ShopErrorView.swift
//  Parra
//
//  Created by Mick MacCallum on 9/30/24.
//

import Parra
import SwiftUI

struct ShopErrorView: View {
    @Environment(\.parraComponentFactory) private var componentFactory
    let error: Error

    var body: some View {
        VStack {
            componentFactory
                .buildEmptyState(
                    config: .errorDefault,
                    content: .storefrontError,
                    onPrimaryAction: nil,
                    onSecondaryAction: nil
                )
        }
        .onAppear {
            ParraLogger.error("Error loading shop", error)
        }
    }
}
