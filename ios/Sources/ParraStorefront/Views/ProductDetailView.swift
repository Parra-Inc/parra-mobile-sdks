//
//  ProductDetailView.swift
//  KbIosApp
//
//  Created by Mick MacCallum on 9/30/24.
//

import Parra
import SwiftUI
import UIKit

@MainActor
struct ProductDetailView: View {
    @Environment(\.parra) private var parra
    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(StorefrontWidget.ContentObserver.self) private var dataModel

    let product: ParraProduct

    @State var footerHeight: CGFloat = 0

    private var images: some View {
        TabView {
            ForEach(product.images, id: \.self) { image in
                ZStack {
                    componentFactory
                        .buildAsyncImage(
                            config: ParraImageConfig(
                                aspectRatio: 1.0,
                                contentMode: .fill
                            ),
                            content: ParraAsyncImageContent(
                                url: image.url,
                                originalSize: image.size
                            )
                        )
                        .overlay(
                            alignment: .topLeading
                        ) {
                            if let altText = image.altText {
                                componentFactory.buildLabel(
                                    text: altText,
                                    localAttributes: ParraAttributes.Label(
                                        text: ParraAttributes.Text(
                                            style: .caption,
                                            color: parraTheme.palette.secondaryText
                                                .shade600
                                                .toParraColor(),
                                            alignment: .leading
                                        )
                                    )
                                )
                                .lineLimit(3)
                                .truncationMode(.tail)
                                .padding()
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .topLeading
                                )
                                .background {
                                    LinearGradient(
                                        gradient: Gradient(
                                            colors: [
                                                .clear,
                                                .black.opacity(0.3),
                                                .black.opacity(0.7),
                                                .black.opacity(0.7)
                                            ]
                                        ),
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                }
                            }
                        }
                }
            }
        }
        .tabViewStyle(
            .page(indexDisplayMode: .automatic)
        )
        .aspectRatio(1.0, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .cornerRadius(16)
    }

    @ViewBuilder private var description: some View {
        if let descriptionMarkdown = product.descriptionMarkdown,
           let attr = try? AttributedString(
               markdown: descriptionMarkdown,
               options: AttributedString.MarkdownParsingOptions(
                   allowsExtendedAttributes: true,
                   interpretedSyntax: .inlineOnlyPreservingWhitespace,
                   failurePolicy: .returnPartiallyParsedIfPossible
               )
           )
        {
            Text(attr)
        } else {
            Text(product.description)
                .font(.body)
        }
    }

    var body: some View {
        @Bindable var dataModel = dataModel

        ScrollView {
            VStack(alignment: .leading, spacing: 5) {
                images
                    .padding(.bottom, 15)

                HStack(alignment: .top) {
                    Text(product.name)
                        .font(.title3)
                        .fontWeight(.bold)

                    Spacer()

                    if let onlineStoreUrl = product.onlineStoreUrl {
                        ShareLink(item: onlineStoreUrl) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }

                DiscountablePriceLabelView(
                    product: product,
                    location: .productDetail
                )
                .padding(.bottom, 5)

                ProductDetailOptionsView(
                    product: product
                )
                .padding(.bottom, 16)

                description

                Spacer()
            }
            .padding([.horizontal, .top])
        }
        .background(parraTheme.palette.primaryBackground)
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CartButton(
                    cartState: $dataModel.cartState
                )
            }
        }
        .onReceive(
            NotificationCenter.default
                .publisher(for: UIApplication.userDidTakeScreenshotNotification)
        ) { _ in
            guard let topVc = UIViewController.topMostViewController() else {
                return
            }

            let activityVC = UIActivityViewController(
                activityItems: [product.onlineStoreUrl as Any],
                applicationActivities: nil
            )

            Task { @MainActor in
                try! await Task.sleep(for: .seconds(1))

                topVc.present(activityVC, animated: true)
            }
        }
    }
}
