//
//  StoreTab.swift
//  ParraDev
//
//  Created by Mick MacCallum on 10/6/24.
//

import SwiftUI
import Parra
import ParraStorefront

struct StoreTab: View {
    @Environment(\.parraTheme) private var parraTheme

    var body: some View {
        ParraStorefrontWidget(
            config: ParraStorefrontConfig(
                shopifyDomain: "",
                shopifyApiKey: ""
            )
        )
    }
}

#Preview {
    ParraAppPreview {
        SampleTab()
    }
}
