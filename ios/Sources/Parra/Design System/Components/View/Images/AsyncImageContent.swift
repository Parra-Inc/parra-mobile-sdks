//
//  AsyncImageContent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/13/25.
//

import SwiftUI

private let blurSize: CGFloat = 32

struct AsyncImageContent: View {
    // MARK: - Internal

    var phase: CachedAsyncImagePhase
    var config: ParraAsyncImageConfig
    var content: ParraAsyncImageContent
    var attributes: ParraAttributes.AsyncImage

    var body: some View {
        imageContent
            .transition(.opacity)
    }

    // MARK: - Private

    @ViewBuilder private var imageContent: some View {
        switch phase {
        case .empty:
            renderBlurHash(for: phase)
        case .success(let image, let size):
            image
                .resizable()
                .aspectRatio(
                    config.aspectRatio ?? size.width / size.height,
                    contentMode: config.contentMode
                )
                .blur(radius: config.blurContent ? 10 : 0, opaque: true)
        case .failure:
            renderBlurHash(for: phase)
        @unknown default:
            EmptyView()
        }
    }

    @ViewBuilder
    private func renderBlurHashOverlay(
        for phase: CachedAsyncImagePhase
    ) -> some View {
        switch phase {
        case .empty:
            if config.showLoadingIndicator {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .tint(ParraColorSwatch.gray.shade300)
            }
        case .failure:
            if config.showFailureIndicator {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.white)
            }
        case .success:
            EmptyView()
        default:
            EmptyView()
        }
    }

    private func renderSolidColor(
        color: Color,
        aspectRatio: CGFloat
    ) -> some View {
        // Preserve the same space even if we aren't showing the
        // blur hash.
        return color.aspectRatio(
            aspectRatio,
            contentMode: .fit
        )
    }

    @ViewBuilder
    private func renderBlurHash(
        for phase: CachedAsyncImagePhase
    ) -> some View {
        let imageSize = content.originalSize.toCGSize
        let aspectRatio = config.aspectRatio ?? imageSize.width / imageSize.height

        let size = if imageSize.width > imageSize.height {
            CGSize(width: blurSize * aspectRatio, height: blurSize)
        } else if imageSize.width == imageSize.height {
            CGSize(width: blurSize, height: blurSize)
        } else {
            CGSize(width: blurSize, height: blurSize / aspectRatio)
        }

        Group {
            if config.showBlurHash {
                if let blurHash = content.blurHash, let blurImage = Image(
                    blurHash: blurHash,
                    size: size
                ) {
                    blurImage
                        .resizable()
                        .aspectRatio(
                            config.aspectRatio,
                            contentMode: config.contentMode
                        )
                        .clipped()

                } else {
                    renderSolidColor(
                        color: attributes.background?.toParraColor() ?? .clear,
                        aspectRatio: aspectRatio
                    )
                }
            } else {
                renderSolidColor(
                    color: attributes.background?.toParraColor() ?? .clear,
                    aspectRatio: aspectRatio
                )
            }
        }
        .overlay(alignment: .center) {
            renderBlurHashOverlay(for: phase)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }
}

#Preview {
    ParraViewPreview { componentFactory in
        let testContent = ParraAsyncImageContent(
            url: URL(
                string: "https://parra-cdn.com/tenants/201cbcf0-b5d6-4079-9e4d-177ae04cc9f4/creator-updates/0815cbd2-8168-46f0-8881-fac8e7fd9661/attachments/afe3eaf7-b7f5-48df-96d3-a1ea3471419a.png"
            )!,
            blurHash: "UhBzFdXS?dX8eDWXnQWCtTjGWWjIaPj?fkj?",
            originalSize: CGSize(width: 1_075, height: 2_048)
        )

        let testContent2 = ParraAsyncImageContent(
            url: URL(
                string: "https://parra-cdn.com/tenants/0c6583c7-a1ed-4c8e-8373-d728986e6d53/creator-updates/70c882bf-8636-466c-8a37-670db644c308/attachments/2101cf78-44f1-460d-b9a3-9adc48b00ad4.jpg?width=1820&height=1024"
            )!,
            blurHash: "ULFh-Yrs~p~BWBivIAxaNeS1f6ozxuNGx]R%",
            originalSize: CGSize(width: 1_820, height: 1_024)
        )

        let attributes = componentFactory.attributeProvider.asyncImageAttributes(
            content: testContent,
            localAttributes: nil,
            theme: .default
        )

        ScrollView {
            AsyncImageContent(
                phase: .empty,
                config: ParraAsyncImageConfig(),
                content: testContent,
                attributes: attributes
            )

//            AsyncImageContent(
//                phase: .success(
//                    Image(
//                        uiImage: UIImage(
//                            named: "test", // not actually in asset library
//                            in: .module,
//                            with: nil
//                        )!
//                    )
//                ),
//                config: ParraAsyncImageConfig(),
//                content: testContent,
//                attributes: attributes
//            )

            AsyncImageContent(
                phase: .failure(ParraError.message("error")),
                config: ParraAsyncImageConfig(),
                content: testContent,
                attributes: attributes
            )

            AsyncImageContent(
                phase: .empty,
                config: ParraAsyncImageConfig(),
                content: testContent2,
                attributes: attributes
            )

//            AsyncImageContent(
//                phase: .success(
//                    Image(
//                        uiImage: UIImage(
//                            named: "test2", // not actually in asset library
//                            in: .module,
//                            with: nil
//                        )!
//                    )
//                ),
//                config: ParraAsyncImageConfig(),
//                content: testContent2,
//                attributes: attributes
//            )

            AsyncImageContent(
                phase: .failure(ParraError.message("error")),
                config: ParraAsyncImageConfig(),
                content: testContent2,
                attributes: attributes
            )

            Spacer()
        }
    }
}
