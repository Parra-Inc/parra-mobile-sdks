//
//  ParraStorefrontWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 10/6/24.
//

import Buy
import Parra
import ShopifyCheckoutSheetKit
import SwiftUI

struct StorefrontWidget: ParraContainer {
    // MARK: - Lifecycle

    init(
        config: ParraStorefrontConfig,
        contentObserver: ContentObserver
    ) {
        self.config = config
        self._contentObserver = StateObject(wrappedValue: contentObserver)
    }

    // MARK: - Public

    public var body: some View {
        @Bindable var contentObserver = contentObserver

        NavigationStack {
            VStack {
                switch contentObserver.productsState {
                case .loading:
                    ProgressView()
                        .controlSize(.large)
                        .progressViewStyle(CircularProgressViewStyle())
                case .loaded(let products), .refreshing(let products):
                    ProductGridView(
                        products: products
                    )
                case .error(let error):
                    ShopErrorView(error: error)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(parraTheme.palette.primaryBackground)
            .navigationTitle("Products")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CartButton(
                        cartState: $contentObserver.cartState
                    )
                }
            }
            .navigationDestination(
                for: ParraProduct.self
            ) { product in
                ProductDetailView(product: product)
            }
            .navigationDestination(
                for: ParraCartLineItem.self
            ) { lineItem in
                if let product = contentObserver.findProduct(for: lineItem) {
                    ProductDetailView(product: product)
                } else {
                    componentFactory.buildEmptyState(
                        config: .default,
                        content: .storefrontProductMissing
                    )
                }
            }
            .navigationDestination(
                for: String.self
            ) { location in
                if location == "cart" {
                    CartView()
                }
            }
        }
        // inject data model instance into env for child views
        .environment(contentObserver)
        .onChange(
            of: parraAuthState,
            initial: true
        ) { _, newValue in
            contentObserver.performCartSetup(
                as: newValue.user
            )
        }
        .task {
            ShopifyCheckoutSheetKit.configuration.colorScheme = colorScheme
            ShopifyCheckoutSheetKit.configuration.backgroundColor = UIColor(
                parraTheme.palette.primaryBackground
            )
            ShopifyCheckoutSheetKit.configuration.tintColor = UIColor(
                parraTheme.palette.primary.toParraColor()
            )
        }
    }

    // MARK: - Internal

    @StateObject var contentObserver: ContentObserver
    let config: ParraStorefrontConfig

    // MARK: - Private

    @Environment(\.parra) private var parra
    @Environment(\.parraAuthState) private var parraAuthState
    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraPreferredAppearance) private var parraPreferredAppearance

    private var colorScheme: ShopifyCheckoutSheetKit.Configuration.ColorScheme {
        switch parraPreferredAppearance.wrappedValue {
        case .dark:
            return .dark
        case .light:
            return .light
        case .system:
            return .automatic
        }
    }
}

public struct ParraStorefrontWidget: View {
    // MARK: - Lifecycle

    public init(
        config: ParraStorefrontConfig
    ) {
        self.config = config
    }

    // MARK: - Public

    public let config: ParraStorefrontConfig

    public var body: some View {
        let container: StorefrontWidget = Parra.containerRenderer.renderContainer(
            params: StorefrontWidget.ContentObserver.InitialParams(
                config: config,
                productsResponse: nil
            ),
            config: config
        )

        return container
    }

    // MARK: - Internal
}

#Preview {
    ParraContainerPreview<StorefrontWidget>(
        config: ParraStorefrontConfig(
            shopifyDomain: "",
            shopifyApiKey: ""
        )
    ) { _, _, config in
        StorefrontWidget(
            config: config,
            contentObserver: StorefrontWidget.ContentObserver(
                initialParams: StorefrontWidget.ContentObserver.InitialParams(
                    config: config,
                    productsResponse: nil
                )
            )
        )
    }
}
