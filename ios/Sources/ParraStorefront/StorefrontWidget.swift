//
//  StorefrontWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 10/12/24.
//

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
        NavigationStack {
            VStack {
                ProductGridView(
                    products: contentObserver.productPaginator.items
                )
                .redacted(
                    when: contentObserver.productPaginator.isShowingPlaceholders
                )
                .emptyPlaceholder(products) {
                    if !contentObserver.productPaginator.isLoading {
                        componentFactory.buildEmptyState(
                            config: .default,
                            content: contentObserver.content.emptyStateView
                        )
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity
                        )
                    } else {
                        EmptyView()
                    }
                }
                .errorPlaceholder(contentObserver.productPaginator.error) {
                    componentFactory.buildEmptyState(
                        config: .errorDefault,
                        content: contentObserver.content.errorStateView
                    )
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(parraTheme.palette.primaryBackground)
            .navigationTitle(contentObserver.config.navigationTitle)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CartButton(
                        cartState: $contentObserver.cartState
                    )
                }

                if contentObserver.config.showDismissButton {
                    ToolbarItem(placement: .topBarTrailing) {
                        ParraDismissButton()
                    }
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
                        content: contentObserver.content.productMissingView
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
        .onAppear {
            contentObserver.loadInitialFeedItems()
        }
    }

    // MARK: - Internal

    @StateObject var contentObserver: ContentObserver
    let config: ParraStorefrontConfig

    var products: Binding<[ParraProduct]> {
        return $contentObserver.productPaginator.items
    }

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
