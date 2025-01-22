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
        contentObserver: ContentObserver
    ) {
        self.config = config
        self._contentObserver = StateObject(wrappedValue: contentObserver)
    }

    // MARK: - Internal

    @StateObject var contentObserver: ContentObserver
    let config: ParraPaywallConfig

    var body: some View {
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
    }

    // MARK: - Private

    @Environment(\.parraAppInfo) private var appInfo
    @Environment(\.parraTheme) private var theme

    @Environment(\.parraComponentFactory) private var componentFactory

    @ViewBuilder
    @MainActor private var subscriptionStoreView: some View {
        if ParraAppEnvironment.isDebugParraDevApp {
            // Hard-coded to match the group id in the Configuration.storekit file.
            SubscriptionStoreView(
                groupID: "4EEAFE70",
                visibleRelationships: config.visibleRelationships
            )
        } else {
            // This is necessary because you can't pass an optional marketing
            // content builder function, and passing one that returns an empty
            // view causes the default title to be omitted.
            switch contentObserver.initialParams.paywallProducts {
            case .groupId(let groupId):
                if let marketingContent = config.marketingContent {
                    SubscriptionStoreView(
                        groupID: groupId,
                        visibleRelationships: config.visibleRelationships
                    ) {
                        AnyView(marketingContent())
                    }
                } else {
                    SubscriptionStoreView(
                        groupID: groupId,
                        visibleRelationships: config.visibleRelationships
                    )
                }
            case .productIds(let productIds):
                if let marketingContent = config.marketingContent {
                    SubscriptionStoreView(
                        productIDs: productIds
                    ) {
                        AnyView(marketingContent())
                    }
                } else {
                    SubscriptionStoreView(
                        productIDs: productIds
                    )
                }
            case .products(let products):
                if let marketingContent = config.marketingContent {
                    SubscriptionStoreView(
                        subscriptions: products
                    ) {
                        AnyView(marketingContent())
                    }
                } else {
                    SubscriptionStoreView(
                        subscriptions: products
                    )
                }
            }
        }
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
