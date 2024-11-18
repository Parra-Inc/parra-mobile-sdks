//
//  TipJarWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 11/15/24.
//

import StoreKit
import SwiftUI

struct TipJarWidget: ParraContainer {
    // MARK: - Lifecycle

    init(
        config: ParraTipJarConfig,
        contentObserver: ContentObserver
    ) {
        self.config = config
        self._contentObserver = StateObject(wrappedValue: contentObserver)
    }

    // MARK: - Internal

    @StateObject var contentObserver: ContentObserver
    let config: ParraTipJarConfig

    @ViewBuilder var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                marketingContent

                switch contentObserver.state {
                case .loading(let productIds):
                    loadingStoreView(for: productIds)
                        .parraProductViewStyle(for: config.productViewStyle)
                case .loaded(let products):
                    storeView(for: products)
                        .parraProductViewStyle(for: config.productViewStyle)
                case .failed:
                    componentFactory.buildLabel(
                        text: "Failed to load products.",
                        localAttributes: ParraAttributes.Label(
                            text: ParraAttributes.Text(
                                style: .callout,
                                color: theme.palette.error.toParraColor()
                            )
                        )
                    )
                }
            }
            .safeAreaPadding(.horizontal)
        }
        .renderToast(toast: $alertManager.currentToast)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ParraDismissButton()
            }
        }
        .onReceive(
            ParraUserEntitlements.shared.purchaseCompletePublisher
        ) { tx in
            // Only notify success here if a purchase message is received for
            // one of the products being displayed.
            guard contentObserver.state.productIds.contains(tx.productID) else {
                return
            }

            alertManager.showToast(
                for: 5.0,
                in: .topCenter,
                level: .success,
                content: ParraAlertContent(
                    title: ParraLabelContent(
                        text: config.thankYouContent.title
                    ),
                    subtitle: ParraLabelContent(
                        text: config.thankYouContent.subtitle
                    ),
                    icon: config.thankYouContent.icon,
                    dismiss: nil
                ),
                attributes: ParraAttributes.ToastAlert(
                    background: config.thankYouContent.backgroundColor
                        ?? theme.palette.success.toParraColor()
                )
            )
        }
    }

    // MARK: - Private

    @Environment(\.parraAppInfo) private var appInfo
    @Environment(\.parraTheme) private var theme

    @Environment(\.parraComponentFactory) private var componentFactory
    @State private var alertManager: ParraAlertManager = .shared

    @ViewBuilder private var marketingContent: some View {
        switch config.marketingContent {
        case .custom(let builder):
            AnyView(builder())
        case .default(let marketingContent):
            VStack(alignment: .center) {
                withContent(content: marketingContent.icon) { content in
                    componentFactory.buildImage(
                        content: content,
                        localAttributes: ParraAttributes.Image(
                            tint: .blue
                        )
                    )
                    .foregroundStyle(.blue)
                }
                .frame(
                    width: 100,
                    height: 100
                )

                componentFactory.buildLabel(
                    text: marketingContent.title,
                    localAttributes: .default(with: .title)
                )
                .padding(.vertical, 12)

                componentFactory.buildLabel(
                    text: marketingContent.subtitle,
                    localAttributes: .default(with: .body)
                )
                .lineLimit(5)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
            }
            .frame(
                maxWidth: .infinity
            )
            .padding(.top, 34)
            .padding(.bottom, 50)
        }
    }

    @ViewBuilder
    private func loadingStoreView(
        for productIds: [String]
    ) -> some View {
        VStack {
            ForEach(productIds, id: \.self) { productId in
                ProductView(
                    id: productId,
                    prefersPromotionalIcon: config.productsPreferPromotionalIcon
                ) {
                    if let builder = config.productIconBuilder {
                        AnyView(builder(productId))
                    } else {
                        EmptyView()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func storeView(
        for products: [Product]
    ) -> some View {
        VStack {
            ForEach(products) { product in
                ProductView(
                    product,
                    prefersPromotionalIcon: config.productsPreferPromotionalIcon
                ) {
                    EmptyView()
                }
            }
        }
    }
}

private extension View {
    @ViewBuilder
    func parraProductViewStyle(
        for productViewStyle: ParraTipJarConfig.ProductViewStyle
    ) -> some View {
        switch productViewStyle {
        case .automatic:
            self.productViewStyle(.automatic)
        case .compact:
            self.productViewStyle(.compact)
        case .large:
            self.productViewStyle(.large)
        case .regular:
            self.productViewStyle(.regular)
        @unknown default:
            self.productViewStyle(.compact)
        }
    }
}
