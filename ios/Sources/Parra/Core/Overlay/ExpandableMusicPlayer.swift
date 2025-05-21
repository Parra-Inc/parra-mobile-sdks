//
//  ExpandableMusicPlayer.swift
//  Parra
//
//  Created by Mick MacCallum on 5/19/25.
//

import SwiftUI

struct ExpandableMusicPlayer: View {
    // MARK: - Internal

    var body: some View {
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets

            ZStack(alignment: expandPlayer ? .top : .bottom) {
                Color.clear.frame(
                    maxWidth: .infinity
                )

                if let media = player.currentMedia {
                    MiniOverlayPlayer(
                        media: media,
                        expandPlayer: $expandPlayer,
                        animation: animation
                    ) {
                        withAnimation(.smooth(duration: 0.3, extraBounce: 0)) {
                            accumulatedOffsetY = 0
                            offsetY = 0
                            expandPlayer = true
                        }

                        /// Reszing Window When Opening Player
                        UIView.animate(withDuration: 0.3) {
                            resizeWindow(0.1)
                        }
                    }
                    .opacity(expandPlayer ? 0 : 1)

                    ExpandedMediaPlayerView(
                        media: media,
                        size: size,
                        safeArea: safeArea,
                        expandPlayer: $expandPlayer,
                        animation: animation
                    )
                    .opacity(expandPlayer ? 1 : 0)
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, expandPlayer ? 0 : safeArea.bottom + 20)
            .padding(.horizontal, expandPlayer ? 0 : 15)
            .offset(y: offsetY)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if expandPlayer {
                            let translation = max(value.translation.height, 0)
                            offsetY = translation
                            windowProgress = max(min(translation / size.height, 1), 0) *
                                0.1

                            resizeWindow(0.1 - windowProgress)
                        } else {
                            offsetY = value.translation.height + accumulatedOffsetY
                        }
                    }
                    .onEnded { value in
                        if expandPlayer {
                            let translation = max(value.translation.height, 0)
                            let velocity = value.velocity.height / 5

                            withAnimation(.smooth(duration: 0.3, extraBounce: 0)) {
                                if (translation + velocity) > (size.height * 0.5) {
                                    /// Closing View
                                    expandPlayer = false
                                    windowProgress = 0
                                    /// Resetting Window To Identity With Animation
                                    resetWindowWithAnimation()
                                } else {
                                    /// Reset Window To 0.1 With Animation
                                    UIView.animate(withDuration: 0.3) {
                                        resizeWindow(0.1)
                                    }
                                }

                                offsetY = 0
                            }
                        } else {
                            offsetY = value.translation.height + accumulatedOffsetY
                            accumulatedOffsetY = offsetY
                        }
                    }
            )
            .ignoresSafeArea()
        }
        .onAppear {
            if let window = (
                UIApplication.shared.connectedScenes.first as? UIWindowScene
            )?.keyWindow, mainWindow == nil {
                mainWindow = window
            }
        }
    }

    func resizeWindow(_ progress: CGFloat) {
        if let mainWindow = mainWindow?.subviews.first {
            let offsetY = (mainWindow.frame.height * progress) / 2

            /// Your Custom Corner Radius
            mainWindow.layer.cornerRadius = (progress / 0.1) * 30
            mainWindow.layer.masksToBounds = true

            mainWindow.transform = .identity.scaledBy(
                x: 1 - progress,
                y: 1 - progress
            )
            .translatedBy(
                x: 0,
                y: offsetY
            )
        }
    }

    func resetWindowWithAnimation() {
        if let mainWindow = mainWindow?.subviews.first {
            UIView.animate(withDuration: 0.3) {
                mainWindow.layer.cornerRadius = 0
                mainWindow.transform = .identity
            }
        }
    }

    // MARK: - Private

    /// View Properties
    @State private var expandPlayer: Bool = false
    @State private var offsetY: CGFloat = 0
    @State private var accumulatedOffsetY: CGFloat = 0
    @State private var mainWindow: UIWindow?
    @State private var windowProgress: CGFloat = 0
    @Namespace private var animation

    @State private var player = MediaPlaybackManager.shared

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory
}
