//
//  StorefrontWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 10/12/24.
//

import Buy
import Parra
import ShopifyCheckoutSheetKit
import SwiftUI

struct StorefrontWidget: ParraContainer {
    // MARK: - Lifecycle

    init(
        config: ParraStorefrontWidgetConfig,
        contentObserver: ContentObserver,
        navigationPath: Binding<NavigationPath>
    ) {
        self.config = config
        self._contentObserver = StateObject(wrappedValue: contentObserver)
    }

    // MARK: - Public

    public var body: some View {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(parraTheme.palette.primaryBackground)
        .navigationTitle(contentObserver.config.navigationTitle)
        .toolbar {
            if contentObserver.config.showDismissButton {
                ToolbarItem(placement: .topBarLeading) {
                    CartButton(
                        cartState: $contentObserver.cartState
                    )
                }

                ToolbarItem(placement: .topBarLeading) {
                    SortButton(sortOrder: $contentObserver.sortOrder)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    ParraDismissButton()
                }
            } else {
                ToolbarItem(placement: .topBarLeading) {
                    SortButton(sortOrder: $contentObserver.sortOrder)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    CartButton(
                        cartState: $contentObserver.cartState
                    )
                }
            }
        }
        .navigationDestination(
            for: ParraCartLineItem.self
        ) { lineItem in
            if let product = contentObserver.findProduct(for: lineItem) {
                ProductDetailView(product: product)
                    .environment(contentObserver)
            } else {
                componentFactory.buildEmptyState(
                    config: .default,
                    content: contentObserver.content.productMissingView
                )
            }
        }
        .navigationDestination(
            for: String.self
        ) { path in
            let components = path.split(separator: "/")

            if let location = components.first {
                if location == "cart" {
                    CartView()
                        .environment(contentObserver)

                } else if location == "product", let productId = components[safe: 1],
                          !productId.isEmpty
                {
                    if let product = contentObserver.queryProduct(
                        by: String(productId)
                    ) {
                        ProductDetailView(product: product)
                            .environment(contentObserver)
                    } else {
                        componentFactory.buildEmptyState(
                            config: .default,
                            content: contentObserver.content.productMissingView
                        )
                    }
                } else {
                    componentFactory.buildEmptyState(
                        config: .default,
                        content: contentObserver.content.productMissingView
                    )
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
            contentObserver.loadInitialProducts()
        }
        .sheet(
            isPresented: Binding<Bool>(
                get: {
                    switch contentObserver.cartState {
                    case .checkoutComplete:
                        return true
                    default:
                        return false
                    }
                },
                set: { _ in }
            )
        ) {
            navigationPath = NavigationPath()

            contentObserver.refreshExpiredCart()
        } content: {
            switch contentObserver.cartState {
            case .checkoutComplete(let orderDetails):
                NavigationStack {
                    OrderReceiptView(details: orderDetails)
                }
            default:
                EmptyView()
            }
        }
    }

    // MARK: - Internal

    @StateObject var contentObserver: ContentObserver
    let config: ParraStorefrontWidgetConfig

    var products: Binding<[ParraProduct]> {
        return $contentObserver.productPaginator.items
    }

    // MARK: - Private

    @State private var navigationPath = NavigationPath()

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
        config: ParraStorefrontWidgetConfig()
    ) { _, _, config in
        StorefrontWidget(
            config: config,
            contentObserver: StorefrontWidget.ContentObserver(
                initialParams: StorefrontWidget.ContentObserver.InitialParams(
                    config: config,
                    delegate: nil,
                    productsResponse: nil
                )
            ),
            navigationPath: .constant(.init())
        )
    }
}
