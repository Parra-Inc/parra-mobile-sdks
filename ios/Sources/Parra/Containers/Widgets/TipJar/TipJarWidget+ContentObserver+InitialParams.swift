//
//  TipJarWidget+ContentObserver+InitialParams.swift
//  Parra
//
//  Created by Mick MacCallum on 11/15/24.
//

import StoreKit
import SwiftUI

enum TipJarProducts: Equatable {
    case products([Product])
    case productIds([String])
}

// MARK: - TipJarWidget.ContentObserver.InitialParams

extension TipJarWidget.ContentObserver {
    struct InitialParams {
        let products: TipJarProducts
        let config: ParraTipJarConfig
        let api: API
    }
}
