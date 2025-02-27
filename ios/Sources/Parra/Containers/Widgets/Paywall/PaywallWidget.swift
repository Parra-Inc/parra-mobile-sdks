//
//  PaywallWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 11/12/24.
//

import StoreKit
import SwiftUI

struct PaywallWidget: ParraContainer {
    // MARK: - Lifecycle

    init(
        config: ParraPaywallConfig,
        contentObserver: ContentObserver,
        navigationPath: Binding<NavigationPath>
    ) {
        self.config = config
        self._contentObserver = StateObject(wrappedValue: contentObserver)
    }

    // MARK: - Internal

    @StateObject var contentObserver: ContentObserver
    let config: ParraPaywallConfig

    var body: some View {
        content
            .renderToast(toast: $alertManager.currentToast)
            .onReceive(
                ParraUserEntitlements.shared.purchaseCompletePublisher
            ) { tx, error in
                let productIds = contentObserver.initialParams.paywallProducts.productIds

                // Only notify success here if a purchase message is received for
                // one of the products being displayed. We also show it if there
                // are no product IDs which indicates a groupId was used so we
                // can't be sure that products are in the group.
                if let productIds, !productIds.contains(tx.productID) {
                    return
                }

                if error != nil {
                    alertManager.showToast(
                        for: 5.0,
                        in: .topCenter,
                        level: .error,
                        content: ParraAlertContent(
                            title: ParraLabelContent(
                                text: config.purchaseErrorContent.title
                            ),
                            subtitle: ParraLabelContent(
                                text: config.purchaseErrorContent.subtitle
                            ),
                            icon: config.purchaseErrorContent.icon,
                            dismiss: nil
                        ),
                        attributes: ParraAttributes.ToastAlert(
                            background: config.purchaseErrorContent.backgroundColor
                                ?? theme.palette.error.toParraColor()
                        )
                    )
                } else {
                    if config.dismissOnSuccess {
                        contentObserver.dismiss(with: nil)
                    } else {
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
            }
    }

    // MARK: - Private

    @State private var alertManager: ParraAlertManager = .shared

    @Environment(\.parraAppInfo) private var appInfo
    @Environment(\.parraTheme) private var theme

    @Environment(\.parraComponentFactory) private var componentFactory

    @ViewBuilder private var content: some View {
        if contentObserver.initialParams.iapType.isSubscription {
            subscriptionStoreView
                .subscriptionStorePolicyForegroundStyle(
                    theme.palette.primary.toParraColor(),
                    theme.palette.secondary.toParraColor()
                )
                .subscriptionStoreControlBackground(
                    SubscriptionStoreControlBackground.gradientMaterialOnScroll
                )
                .subscriptionStorePickerItemBackground(
                    theme.palette.primaryBackground.toParraColor()
                )
                .subscriptionPolicy(
                    for: appInfo.legal.privacyPolicy,
                    kind: .privacyPolicy
                )
                .subscriptionPolicy(
                    for: appInfo.legal.termsOfService,
                    kind: .termsOfService
                )
                .versionedSubscriptionStoreControlStyle()
        } else {
            storeView
                .productViewStyle(.compact)
        }
    }

    @ViewBuilder private var marketingContent: some View {
        if let overrideMarketingContent = config.marketingContent {
            AnyView(overrideMarketingContent())
        } else {
            VStack(alignment: .center, spacing: 30) {
                if let sections = contentObserver.initialParams.sections {
                    ForEach(sections) { section in

                        switch section {
                        case .paywallHeaderSection(let header):
                            renderMarketingHeader(
                                title: header.title,
                                subtitle: header.description,
                                icon: header.icon
                            )
                        case .paywallOfferingSection(let offeringSection):
                            VStack(alignment: .leading, spacing: 16) {
                                ForEach(offeringSection.offerings) { offering in
                                    componentFactory.buildLabel(
                                        content: ParraLabelContent(
                                            text: offering.title,
                                            icon: .symbol("checkmark.circle.fill")
                                        ),
                                        localAttributes: .init(
                                            text: ParraAttributes
                                                .Text(
                                                    style: .subheadline,
                                                    alignment: .leading
                                                ),
                                            icon: ParraAttributes.Image(
                                                tint: theme.palette.primary.toParraColor()
                                            )
                                        )
                                    )
                                    .frame(
                                        maxWidth: .infinity,
                                        alignment: .leading
                                    )
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(3)
                                }
                            }
                        }
                    }
                }
            }
            .safeAreaPadding(30)
            .padding(.top, 28)
        }
    }

    private var hasMarketingContent: Bool {
        if config.marketingContent != nil {
            return true
        }

        if contentObserver.initialParams.marketingContent != nil {
            return true
        }

        if let sections = contentObserver.initialParams.sections {
            return sections.isEmpty
        }

        return false
    }

    @ViewBuilder
    @MainActor private var storeView: some View {
        switch contentObserver.initialParams.paywallProducts {
        case .products(let products):
            NavigationStack {
                VStack {
                    if hasMarketingContent {
                        marketingContent
                    }

                    let iaps = products.filter { product in
                        return product.type == .consumable || product
                            .type == .nonConsumable
                    }

                    ForEach(iaps) { product in
                        ProductView(product) {
                            // To prevent showing an empty icon
                            EmptyView()
                        }
                        .productDescription(.hidden)
                        .padding(.horizontal, 24)
                    }
                }
                .toolbar {
                    if config.showsDismissButton {
                        ToolbarItem(placement: .topBarTrailing) {
                            ParraDismissButton()
                        }
                    }
                }
            }
        case .productIds(let productIds):
            // TODO: Marketing content?
            StoreView(ids: productIds)
        case .groupId(let string):
            // Invalid state. Group ID should only be for subscriptions.
            EmptyView()
        }
    }

    @ViewBuilder
    @MainActor private var subscriptionStoreView: some View {
        // This is necessary because you can't pass an optional marketing
        // content builder function, and passing one that returns an empty
        // view causes the default title to be omitted.
        switch contentObserver.initialParams.paywallProducts {
        case .groupId(let groupId):
            if ParraAppEnvironment.isDebugParraDevApp {
                // Hard-coded to match the group id in the Configuration.storekit file.
                if hasMarketingContent {
                    SubscriptionStoreView(
                        groupID: "4EEAFE70",
                        visibleRelationships: config.visibleRelationships
                    ) {
                        marketingContent
                    }
                } else {
                    SubscriptionStoreView(
                        groupID: "4EEAFE70",
                        visibleRelationships: config.visibleRelationships
                    )
                }

            } else {
                if hasMarketingContent {
                    SubscriptionStoreView(
                        groupID: groupId,
                        visibleRelationships: config.visibleRelationships
                    ) {
                        marketingContent
                    }
                } else {
                    SubscriptionStoreView(
                        groupID: groupId,
                        visibleRelationships: config.visibleRelationships
                    )
                }
            }
        case .productIds(let productIds):
            if hasMarketingContent {
                SubscriptionStoreView(
                    productIDs: productIds
                ) {
                    marketingContent
                }
            } else {
                SubscriptionStoreView(
                    productIDs: productIds
                )
            }
        case .products(let products):
            if hasMarketingContent {
                SubscriptionStoreView(
                    subscriptions: products
                ) {
                    marketingContent
                }
            } else {
                SubscriptionStoreView(
                    subscriptions: products
                )
            }
        }
    }

    @ViewBuilder
    private func renderMarketingHeader(
        title: String,
        subtitle: String?,
        icon: ParraImageAsset?
    ) -> some View {
        withContent(
            content: icon
        ) { content in
            componentFactory.buildAsyncImage(
                config: ParraAsyncImageConfig(
                    showBlurHash: false
                ),
                content: ParraAsyncImageContent(content),
                localAttributes: ParraAttributes.AsyncImage(
                    size: CGSize(width: 96, height: 96),
                    cornerRadius: .xxl,
                    padding: .zero
                )
            )
        }

        VStack(spacing: 8) {
            componentFactory.buildLabel(
                text: title,
                localAttributes: .default(
                    with: .largeTitle,
                    alignment: .center
                )
            )
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)

            withContent(
                content: subtitle
            ) { content in
                componentFactory.buildLabel(
                    text: content,
                    localAttributes: .default(
                        with: .subheadline,
                        alignment: .center
                    )
                )
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.bottom, 12)
    }
}

private extension View {
    @ViewBuilder
    func subscriptionPolicy(
        for legalDocument: ParraLegalDocument?,
        kind: SubscriptionStorePolicyKind
    ) -> some View {
        if let legalDocument {
            subscriptionStorePolicyDestination(
                for: kind
            ) {
                ParraLegalDocumentView(legalDocument: legalDocument)
            }
        } else {
            self
        }
    }

    @ViewBuilder
    func versionedSubscriptionStoreControlStyle() -> some View {
        if #available(iOS 18.0, *) {
            subscriptionStoreControlStyle(
                .compactPicker
            )
        } else {
            subscriptionStoreControlStyle(
                .automatic
            )
        }
    }
}
