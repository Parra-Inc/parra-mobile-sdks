//
//  ProductDetailView.swift
//  Parra
//
//  Created by Mick MacCallum on 9/30/24.
//

import Parra
import SwiftUI
import UIKit

@MainActor
struct ProductDetailView: View {
    // MARK: - Lifecycle

    init(product: ParraProduct) {
        self.product = product

        _selectedVariant = State(
            wrappedValue: product.variants[0]
        )
    }

    // MARK: - Internal

    let product: ParraProduct

    @State var footerHeight: CGFloat = 0

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

                ProductVariantPriceLabelView(
                    selectedVariant: $selectedVariant
                )
                .padding(.bottom, 5)

                ProductDetailOptionsView(
                    product: product,
                    selectedVariant: $selectedVariant
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
        .onAppear {
            Task {
                let imageUrls = product.images.map { image in
                    return shopifyCdnUrl(for: image.url)
                }

                await ParraImageAsset.precacheAssets(at: imageUrls)
            }
        }
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(StorefrontWidget.ContentObserver.self) private var dataModel

    @State private var selectedVariant: ParraProductVariant

    private var images: some View {
        GeometryReader { proxy in
            TabView {
                ForEach(product.images, id: \.self) { image in
                    ZStack {
                        let cdnUrl = shopifyCdnUrl(for: image.url)

                        componentFactory.buildAsyncImage(
                            config: ParraAsyncImageConfig(
                                aspectRatio: 1.0,
                                contentMode: .fill
                            ),
                            content: ParraAsyncImageContent(
                                url: cdnUrl,
                                originalSize: image.size ?? CGSize(
                                    width: proxy.size.width,
                                    height: proxy.size.width
                                )
                            )
                        )
                        .cornerRadius(16)
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
        }
        .tabViewStyle(
            .page(indexDisplayMode: .automatic)
        )
        .aspectRatio(1.0, contentMode: .fit)
        .frame(maxWidth: .infinity)
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

    private func shopifyCdnUrl(for url: URL) -> URL {
        return url.appending(
            queryItems: [
                URLQueryItem(
                    name: "width",
                    value: "\(Int(UIScreen.main.bounds.width * UIScreen.main.scale))"
                ),
                URLQueryItem(
                    name: "crop",
                    value: "center"
                )
            ]
        )
    }
}
