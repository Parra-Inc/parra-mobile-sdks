//
//  ShopTab.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import Parra
import ParraStorefront
import SwiftUI

struct ShopTab: View {
    @Binding var navigationPath: NavigationPath

    var body: some View {
        NavigationStack(path: $navigationPath) {
            {% if template.tabs.shop.shopify %}ParraStorefrontWidget(
                config: ParraStorefrontWidgetConfig(
                    navigationTitle: "{{ template.tabs.shop.title }}",
                    checkoutAttributes: {% if template.tabs.shop.shopify.attribution_source %}["attribution_source": "{{ template.tabs.shop.shopify.attribution_source }}"]{% else %}[:]{% endif %},
                    checkoutDiscountCodes: [{% if template.tabs.shop.shopify.discount_code %}"{{ template.tabs.shop.shopify.discount_code }}"{% endif %}]
                ),
                navigationPath: $navigationPath
            ){% else %}EmptyView(){% endif %}
        }
    }
}

#Preview {
    ParraAppPreview {
        ShopTab(navigationPath: .constant(NavigationPath()))
    }
}
