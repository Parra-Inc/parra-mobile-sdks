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
            .optionalSubscriptionStorePolicyDestination(
                url: appInfo.legal.privacyPolicy?.url,
                for: SubscriptionStorePolicyKind.privacyPolicy
            )
            .optionalSubscriptionStorePolicyDestination(
                url: appInfo.legal.termsOfService?.url,
                for: SubscriptionStorePolicyKind.termsOfService
            )
            .versionedSubscriptionStoreControlStyle()
    }

    // MARK: - Private

    @Environment(\.parraAppInfo) private var appInfo
    @Environment(\.parraTheme) private var theme

    @Environment(\.parraComponentFactory) private var componentFactory

    @ViewBuilder private var marketingContent: some View {
        VStack(alignment: .center) {
            componentFactory.buildImage(
                content: contentObserver.content.image
            )
            .frame(
                width: 100,
                height: 100
            )

            componentFactory.buildLabel(
                content: contentObserver.content.title,
                localAttributes: .default(with: .title)
            )

            componentFactory.buildLabel(
                content: contentObserver.content.subtitle,
                localAttributes: .default(with: .body)
            )
        }
        .padding(.top, 34)
    }

    @ViewBuilder private var subscriptionStoreView: some View {
        switch contentObserver.initialParams.paywallProducts {
        case .groupId(let groupId):
            SubscriptionStoreView(
                groupID: groupId
            ) {
                marketingContent
            }
        case .productIds(let productIds):
            SubscriptionStoreView(
                productIDs: productIds
            ) {
                marketingContent
            }
        case .products(let products):
            SubscriptionStoreView(
                subscriptions: products
            ) {
                marketingContent
            }
        }
    }
}

extension View {
    @ViewBuilder
    func optionalSubscriptionStorePolicyDestination(
        url: URL?,
        for button: SubscriptionStorePolicyKind
    ) -> some View {
        if let url {
            subscriptionStorePolicyDestination(
                url: url,
                for: button
            )
        } else {
            self
        }
    }

    @ViewBuilder
    func versionedSubscriptionStoreControlStyle() -> some View {
        if #available(iOS 18.0, *) {
            subscriptionStoreControlStyle(
                .prominentPicker
            )
        } else {
            subscriptionStoreControlStyle(
                .automatic
            )
        }
    }
}
