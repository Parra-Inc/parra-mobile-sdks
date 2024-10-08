//
//  ShopViewModel+ProductState.swift
//  KbIosApp
//
//  Created by Mick MacCallum on 9/30/24.
//

import Parra
import SwiftUI

extension ParraStorefrontWidget.ContentObserver {
    enum ProductState: Equatable {
        case loading
        case refreshing([ParraProduct])
        case loaded(
            _ products: [ParraProduct]
        )
        case error(ParraStorefrontError)

        // MARK: - Internal

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
