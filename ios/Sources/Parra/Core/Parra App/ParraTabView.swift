//
//  ParraTabView.swift
//  Parra
//
//  Created by Mick MacCallum on 5/21/25.
//

import SwiftUI

public struct ParraTabView<SelectionValue, Content>: View
    where SelectionValue: Hashable, Content: View
{
    // MARK: - Lifecycle

    public init(
        selection: Binding<SelectionValue>,
        mediaPlayerTopMargin: Double = 20.0,
        mediaPlayerBottomMargin: Double = 12.0,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._selection = selection
        self.mediaPlayerTopMargin = mediaPlayerTopMargin
        self.mediaPlayerBottomMargin = mediaPlayerBottomMargin
        self.content = content
    }

    // MARK: - Public

    public var body: some View {
        TabView(
            selection: $selection
        ) {
            content()
                .safeAreaInset(
                    edge: .bottom,
                    spacing: showMiniMediaPlayer ? mediaPlayerTopMargin : 0
                ) {
                    if showMiniMediaPlayer {
                        ExpandableMusicPlayer()
                            .frame(
                                height: MiniOverlayPlayer.Constant.height
                            )
                            .padding(.bottom, mediaPlayerBottomMargin)
                            .transition(
                                .move(edge: .bottom)
                                    .combined(with: .opacity)
                            )
                    }
                }
                .contentMargins(
                    .bottom,
                    EdgeInsets(
                        top: 0,
                        leading: 0,
                        bottom: showMiniMediaPlayer ?
                            (
                                MiniOverlayPlayer.Constant
                                    .height + mediaPlayerBottomMargin
                            ) :
                            0,
                        trailing: 0
                    ),
                    for: .scrollContent
                )
        }
        .onChange(
            of: __showMiniMediaPlayer,
            initial: true
        ) { _, newValue in
            withAnimation {
                showMiniMediaPlayer = newValue
            }
        }
        .onAppear {
            parra.push.requestPushPermission()
        }
    }

    // MARK: - Internal

    @Binding var selection: SelectionValue

    var mediaPlayerTopMargin: Double
    var mediaPlayerBottomMargin: Double

    @ViewBuilder var content: () -> Content

    // MARK: - Private

    @State private var player = MediaPlaybackManager.shared
    @State private var showMiniMediaPlayer = false

    @Environment(\.parra) private var parra

    private var __showMiniMediaPlayer: Bool {
        return !player.shouldHideMiniPlayer && player.state.showMiniPlayer
    }

    private var miniPlayerOffset: Double {
        return MiniOverlayPlayer.Constant
            .height + mediaPlayerTopMargin + mediaPlayerBottomMargin
    }
}
