//
//  StorefrontWidget+ContentObserver+InitialParams.swift
//  Parra
//
//  Created by Mick MacCallum on 10/8/24.
//

import SwiftUI

extension StorefrontWidget.ContentObserver {
    struct InitialParams {
        let config: ParraStorefrontWidgetConfig
        let delegate: ParraStorefrontWidgetDelegate?
        let productsResponse: ParraProductResponse?
    }
}
