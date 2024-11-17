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

    var body: some View {
        ScrollView {
            marketingContent

            storeView
                .productViewStyle(.compact)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ParraDismissButton()
            }
        }
    }

    // MARK: - Private

    @Environment(\.parraAppInfo) private var appInfo
    @Environment(\.parraTheme) private var theme

    @Environment(\.parraComponentFactory) private var componentFactory

    @ViewBuilder private var marketingContent: some View {
        VStack(alignment: .center) {
            withContent(content: contentObserver.content.image) { content in
                componentFactory.buildImage(
                    content: content
                )
            }
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

    @ViewBuilder private var storeView: some View {
        switch contentObserver.initialParams.products {
        case .productIds(let productIds):
            StoreView(ids: productIds, prefersPromotionalIcon: true)
        case .products(let products):
            ForEach(products) { product in
                ProductView(product)
            }
        }
    }
}
