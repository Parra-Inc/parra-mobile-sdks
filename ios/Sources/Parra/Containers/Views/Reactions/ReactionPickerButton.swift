//
//  ReactionPickerButton.swift
//  Parra
//
//  Created by Mick MacCallum on 2/4/25.
//

import SwiftUI

struct ReactionPickerButton: View {
    // MARK: - Lifecycle

    init(
        reactor: StateObject<Reactor>,
        reactionOption: ParraReactionOption,
        showLabels: Bool
    ) {
        self._reactor = reactor
        self.reactionOption = reactionOption
        self.showLabels = showLabels
    }

    // MARK: - Internal

    var body: some View {
        Button {
            if authState.isLoggedIn {
                toggleAnimation = true

                reactor.addNewReaction(option: reactionOption)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    toggleAnimation = false
                }
            } else {
                isRequiredSignInPresented = true
            }
        } label: {
            VStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill((
                        reactor.currentActiveReactionIds
                            .contains(reactionOption.id) ? .blue :
                            Color
                            .gray
                    ).opacity(0.4))
                    .frame(width: 64, height: 64)
                    .overlay {
                        reactionContent(for: reactionOption)
                            .scaleEffect(toggleAnimation ? 1.35 : 1.0)
                            .animation(toggleAnimation ? Animation.easeInOut(
                                duration: 0.1
                            ) : Animation.easeInOut, value: toggleAnimation)
                    }

                if showLabels {
                    Text(reactionOption.name)
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                        .lineLimit(2, reservesSpace: true)
                        .backgroundStyle(.red)
                }
            }
        }
        // Required to prevent highlighting the button then dragging the scroll
        // view from causing the button to be pressed.
        .simultaneousGesture(TapGesture())
        .buttonStyle(.plain)
        .sensoryFeedback(.impact, trigger: toggleAnimation)
        .presentParraSignInWidget(
            isPresented: $isRequiredSignInPresented,
            config: ParraAuthenticationFlowConfig(
                landingScreen: .default(
                    .init(
                        background: theme.palette.primaryBackground.toParraColor(),
                        logoView: signInLogoView,
                        titleView: signInTitleView,
                        bottomView: nil
                    )
                )
            ),
            onDismiss: { type in
                print("Dismissed \(type)")
            }
        )
    }

    // MARK: - Private

    @State private var toggleAnimation: Bool = .init()
    @State private var isRequiredSignInPresented: Bool = false

    private var reactionOption: ParraReactionOption
    private var showLabels: Bool
    @StateObject private var reactor: Reactor

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var theme
    @Environment(\.parraUserEntitlements) private var userEntitlements
    @Environment(\.parraAppInfo) private var appInfo
    @Environment(\.parraAuthState) private var authState

    @ViewBuilder private var signInTitleView: some View {
        componentFactory.buildLabel(
            content: ParraLabelContent(
                text: "Sign in First"
            ),
            localAttributes: ParraAttributes.Label(
                text: ParraAttributes.Text(
                    font: .systemFont(ofSize: 50, weight: .heavy),
                    alignment: .center
                ),
                padding: .md
            )
        )
        .minimumScaleFactor(0.5)
        .lineLimit(2)

        componentFactory.buildLabel(
            content: ParraLabelContent(text: "You must be signed in to add reactions"),
            localAttributes: ParraAttributes.Label(
                text: .default(with: .subheadline),
                padding: .zero
            )
        )
    }

    @ViewBuilder private var signInLogoView: some View {
        if let logo = appInfo.tenant.logo {
            componentFactory.buildAsyncImage(
                content: ParraAsyncImageContent(
                    logo,
                    preferredThumbnailSize: .lg
                ),
                localAttributes: ParraAttributes.AsyncImage(
                    size: CGSize(width: 200, height: 200),
                    padding: .zero
                )
            )
        }
    }

    @ViewBuilder
    private func reactionContent(
        for reactionOption: ParraReactionOption
    ) -> some View {
        switch reactionOption.type {
        case .custom:
            if let url = URL(string: reactionOption.value) {
                if url.lastPathComponent.hasSuffix(".gif") {
                    GifImageView(url: url)
                        .frame(
                            width: 40.0,
                            height: 40.0
                        )
                } else {
                    componentFactory.buildAsyncImage(
                        config: ParraAsyncImageConfig(
                            aspectRatio: 1.0,
                            contentMode: .fit
                        ),
                        content: ParraAsyncImageContent(
                            url: url
                        ),
                        localAttributes: ParraAttributes.AsyncImage(
                            size: CGSize(
                                width: 40.0,
                                height: 40.0
                            )
                        )
                    )
                }
            }
        case .emoji:
            Text(reactionOption.value)
                .font(.system(size: 500))
                .minimumScaleFactor(0.01)
                .frame(
                    width: 40.0,
                    height: 40.0
                )
        }
    }
}
