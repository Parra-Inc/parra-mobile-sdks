//
//  StorefrontWidget+ContentObserver+ProductState.swift
//  Parra
//
//  Created by Mick MacCallum on 9/30/24.
//

import Parra
import SwiftUI

extension StorefrontWidget.ContentObserver {
    enum ProductState: Equatable {
        case loading
        case refreshing([ParraProduct])
        case loaded(
            _ products: [ParraProduct]
        )
        case error(ParraStorefrontError)

        // MARK: - Internal

        var products: [ParraProduct] {
            switch self {
            case .loading, .error:
                return []
            case .refreshing(let products), .loaded(let products):
                return products
            }
        }

        static func == (
            lhs: ProductState,
            rhs: ProductState
        ) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading):
                return true
            case (.loaded(let lhsp), .loaded(let rhsp)):
                return lhsp == rhsp
            case (.refreshing(let lhsp), .refreshing(let rhsp)):
                return lhsp == rhsp
            case (.error(let lhe), .error(let rhe)):
                return lhe.localizedDescription == rhe.localizedDescription
            default:
                return false
            }
        }
    }
}
