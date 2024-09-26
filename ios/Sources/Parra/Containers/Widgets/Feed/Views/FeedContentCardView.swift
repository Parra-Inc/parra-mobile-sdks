//
//  FeedContentCardView.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import SwiftUI

struct ContentCardButtonStyle: PrimitiveButtonStyle {
    // MARK: - Internal

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.accentColor)
            .opacity(isPressed ? 0.8 : 1)
            .animation(.default, value: isPressed)
            .gesture(DragGesture(minimumDistance: 0).onChanged { _ in
                var t = Transaction()
                t.disablesAnimations = true

                withTransaction(t) {
                    isPressed = true
                }
            }.onEnded { _ in
                isPressed = false
                configuration.trigger()
            })
    }

    // MARK: - Private

    @State private var isPressed = false
}

struct FeedContentCardView: View {
    // MARK: - Internal

    let contentCard: ContentCard

    var body: some View {
        Button(action: {
            contentObserver.performActionForContentCard(contentCard)
        }) {
            ZStack {
                withContent(content: contentCard.background?.image) { content in
                    componentFactory.buildAsyncImage(
                        content: ParraAsyncImageContent(
                            url: content.url,
                            originalSize: content.size
                        )
                    )
                }

                VStack(alignment: .leading) {
                    withContent(content: contentCard.title) { content in
                        componentFactory.buildLabel(
                            text: content,
                            localAttributes: ParraAttributes.Label(
                                text: ParraAttributes.Text(
                                    style: .callout,
                                    color: parraTheme.darkPalette?.primaryText
                                        .toParraColor() ?? .white,
                                    alignment: .leading
                                )
                            )
                        )
                        .lineLimit(2)
                        .truncationMode(.tail)
                    }

                    withContent(content: contentCard.description) { content in
                        componentFactory.buildLabel(
                            text: content,
                            localAttributes: ParraAttributes.Label(
                                text: ParraAttributes.Text(
                                    style: .callout,
                                    color: parraTheme.darkPalette?.secondaryText
                                        .toParraColor() ?? .gray,
                                    alignment: .leading
                                )
                            )
                        )
                        .lineLimit(2)
                        .truncationMode(.tail)
                    }
                }
                .padding()
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .bottomLeading
                )
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .background(parraTheme.palette.secondaryBackground)
            .applyCornerRadii(size: .xl, from: parraTheme)
        }
        .buttonStyle(ContentCardButtonStyle())
        .disabled(contentCard.action == nil)
        .onAppear {
            contentObserver.trackContentCardImpression(contentCard)
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme
    @Environment(FeedWidget.ContentObserver.self) private var contentObserver
}

#Preview {
    ParraAppPreview {
        VStack {
            FeedContentCardView(contentCard: ContentCard.validStates()[0])
            FeedContentCardView(contentCard: ContentCard.validStates()[0])
            FeedContentCardView(contentCard: ContentCard.validStates()[0])
        }
    }
}
