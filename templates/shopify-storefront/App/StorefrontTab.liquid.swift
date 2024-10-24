//
//  StorefrontTab.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import Parra
import ParraStorefront
import SwiftUI

struct StorefrontTab: View {
    var body: some View {
        ParraStorefrontWidget(
            config: ParraStorefrontWidgetConfig(
                shopifyDomain: "{{ shopify.domain }}",
                shopifyApiKey: "{{ shopify.api_key }}"
            )
        )
    }
}

#Preview {
    ParraAppPreview {
        StorefrontTab()
    }
}
