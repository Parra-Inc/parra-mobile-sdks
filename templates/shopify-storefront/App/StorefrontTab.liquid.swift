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
    @State var navigationPath = NavigationPath()

    var body: some View {
        {% if shopify and shopify.domain and shopify.api_key %}
        ParraStorefrontWidget(
            navigationPath: $navigationPath
        )
        .navigationTitle("{{ template.tabs.shop.title }}")
        {% else %}
        EmptyView()
        {% endif %}
    }
}

#Preview {
    ParraAppPreview {
        StorefrontTab()
    }
}
