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
        CellButton {
            if authState.isLoggedIn {
                toggleAnimation = true

                reactor.addNewReaction(option: reactionOption)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    toggleAnimation = false
                }
            } else {
                ParraNotificationCenter.default.post(
                    name: Parra.signInRequiredNotification,
                    object: ParraAuthenticationFlowConfig(
                        landingScreen: .default(
                            .defaultWith(
                                title: "Sign in First",
                                subtitle: "You must be signed in to add comments",
                                using: theme,
                                componentFactory: componentFactory,
                                appInfo: appInfo
                            )
                        )
                    )
                )
            }
        } label: {
            VStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        reactor.currentActiveReactionIds
                            .contains(reactionOption.id)
                            ? theme.palette.primaryChipBackground.toParraColor()
                            : theme.palette.secondaryChipBackground.toParraColor()
                    )
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
        .buttonStyle(.plain)
        .sensoryFeedback(.impact, trigger: toggleAnimation)
    }

    // MARK: - Private

    @State private var toggleAnimation: Bool = .init()

    private var reactionOption: ParraReactionOption
    private var showLabels: Bool
    @StateObject private var reactor: Reactor

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var theme
    @Environment(\.parraUserEntitlements) private var userEntitlements
    @Environment(\.parraAppInfo) private var appInfo
    @Environment(\.parraAuthState) private var authState

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
                            url: url,
                            originalSize: CGSize(
                                width: 40.0,
                                height: 40.0
                            )
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
