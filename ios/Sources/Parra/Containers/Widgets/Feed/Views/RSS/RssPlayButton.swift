//
//  RssPlayButton.swift
//  Parra
//
//  Created by Mick MacCallum on 5/21/25.
//

import SwiftUI

struct RssPlayButton: View {
    // MARK: - Internal

    var urlMedia: UrlMedia

    var body: some View {
        if player.currentMedia?.id == urlMedia.id {
            switch player.state {
            case .loading:
                ProgressView()
                    .tint(theme.palette.primaryText.toParraColor())
            case .playing:
                Button {
                    player.pausePlayback()
                } label: {
                    Image(systemName: "pause.fill")
                }
            case .error, .idle, .paused:
                Button {
                    player.resumePlayback()
                } label: {
                    Image(systemName: "play.fill")
                }
            }
        } else {
            Button {
                withAnimation {
                    MediaPlaybackManager.shared.play(urlMedia)
                }
            } label: {
                Image(systemName: "play.fill")
            }
        }
    }

    // MARK: - Private

    @State private var player = MediaPlaybackManager.shared

    @Environment(\.parraTheme) private var theme
}
