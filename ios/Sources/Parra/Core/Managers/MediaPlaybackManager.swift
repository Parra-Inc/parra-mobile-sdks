//
//  MediaPlaybackManager.swift
//  Parra
//
//  Created by Mick MacCallum on 5/15/25.
//

import AVFoundation
import Combine
import MediaPlayer

enum PlaybackState: Equatable {
    case idle
    case loading
    case playing
    case paused
    case error(Error)

    // MARK: - Internal

    static func == (lhs: PlaybackState, rhs: PlaybackState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.loading, .loading):
            return true
        case (.playing, .playing):
            return true
        case (.paused, .paused):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

@Observable
final class MediaPlaybackManager {
    // MARK: - Lifecycle

    private init() {
        setupAudioSession()
        setupRemoteTransportControls()
        setupNotifications()
    }

    deinit {
        cleanupPlayer()
    }

    // MARK: - Internal

    static let shared = MediaPlaybackManager()

    // Current media being played
    private(set) var currentMedia: UrlMedia?

    private(set) var isPlaying: Bool = false

    // Progress tracking
    private(set) var currentTime: TimeInterval = 0
    private(set) var duration: TimeInterval = 0

    var progress: Double = 0 // 0 to 1

    // Playback state
    private(set) var state: PlaybackState = .idle {
        didSet {
            isPlaying = state == .playing
        }
    }

    // MARK: - Public Methods

    func play(_ media: UrlMedia) {
        // If the same media is already loaded, just resume playback
        if let currentMedia, currentMedia.id == media.id {
            resumePlayback()

            return
        }

        // Set new media and reset state
        currentMedia = media
        state = .loading
        currentTime = 0
        duration = 0
        progress = 0

        // Clean up existing player if any
        cleanupPlayer()

        // Create new player with the media URL
        guard let url = URL(string: media.enclosure.url) else {
            state = .error(
                NSError(
                    domain: "MediaPlaybackManager",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]
                )
            )

            return
        }

        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        player!.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible

        // Observe player item status to know when it's ready to play
        playerItem.publisher(for: \.status)
            .sink { [weak self] status in
                guard let self else {
                    return
                }
                switch status {
                case .readyToPlay:
                    duration = playerItem.duration.seconds
                    player?.play()
                    state = .playing
                    updateNowPlayingInfo()
                case .failed:
                    state = .error(
                        playerItem.error ?? NSError(
                            domain: "MediaPlaybackManager",
                            code: 2,
                            userInfo: [NSLocalizedDescriptionKey: "Failed to load media"]
                        )
                    )
                default:
                    break
                }
            }
            .store(in: &cancellables)

        // Add time observer to track playback progress
        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: CMTime(
                seconds: 0.5,
                preferredTimescale: 600
            ),
            queue: .main
        ) { [weak self] time in
            guard let self, let player, let currentItem = player.currentItem else {
                return
            }

            currentTime = time.seconds

            if currentItem.duration.seconds > 0 {
                progress = time.seconds / currentItem.duration.seconds
            }

            // Update now playing info with current time
            updateNowPlayingInfoPlaybackTime()
        }

        updateNowPlayingInfo()
    }

    func pausePlayback() {
        guard state == .playing, let player else {
            return
        }

        player.pause()
        state = .paused

        updateNowPlayingInfoPlaybackState()
    }

    func resumePlayback() {
        guard state == .paused, let player else {
            return
        }

        player.play()
        state = .playing

        updateNowPlayingInfoPlaybackState()
    }

    func skipForward() {
        seek(by: 15)
    }

    func skipBackward() {
        seek(by: -15)
    }

    func seek(to time: TimeInterval) {
        guard let player else {
            return
        }

        let targetTime = CMTime(
            seconds: max(0, min(time, duration)),
            preferredTimescale: 600
        )

        player.seek(to: targetTime) { [weak self] finished in
            if finished {
                self?.updateNowPlayingInfoPlaybackState()
            }
        }
    }

    func seek(by offsetSeconds: TimeInterval) {
        if player == nil {
            return
        }

        let targetTime = currentTime + offsetSeconds

        seek(to: targetTime)
    }

    // MARK: - Private

    // AVPlayer for media playback
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Private Methods

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    private func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()

        // Add handler for play command
        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self else {
                return .commandFailed
            }
            if state == .paused {
                resumePlayback()
                return .success
            }
            return .commandFailed
        }

        // Add handler for pause command
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self else {
                return .commandFailed
            }
            if state == .playing {
                pausePlayback()
                return .success
            }
            return .commandFailed
        }

        // Add handler for skip forward command (15 seconds)
        commandCenter.skipForwardCommand.preferredIntervals = [15]
        commandCenter.skipForwardCommand.addTarget { [weak self] event in
            guard let self else {
                return .commandFailed
            }
            if let event = event as? MPSkipIntervalCommandEvent {
                seek(by: event.interval)
                return .success
            }
            return .commandFailed
        }

        // Add handler for skip backward command (15 seconds)
        commandCenter.skipBackwardCommand.preferredIntervals = [15]
        commandCenter.skipBackwardCommand.addTarget { [weak self] event in
            guard let self else {
                return .commandFailed
            }
            if let event = event as? MPSkipIntervalCommandEvent {
                seek(by: -event.interval)
                return .success
            }
            return .commandFailed
        }

        // Add handler for seeking
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self,
                  let event = event as? MPChangePlaybackPositionCommandEvent else
            {
                return .commandFailed
            }
            seek(to: event.positionTime)
            return .success
        }
    }

    private func updateNowPlayingInfo() {
        guard let currentMedia else {
            return
        }

        var nowPlayingInfo = [String: Any]()

        // Set media metadata
        nowPlayingInfo[MPMediaItemPropertyTitle] = currentMedia.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = currentMedia.author ?? ""

        // Set duration
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration

        // Set current playback time
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime

        // Set playback rate (0.0 = paused, 1.0 = playing)
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = state == .playing ? 1.0 :
            0.0

        // Load and set artwork if available
        if let imageUrl = currentMedia.imageUrl {
            loadArtwork(from: imageUrl) { artwork in
                if let artwork {
                    var updatedInfo = MPNowPlayingInfoCenter.default()
                        .nowPlayingInfo ?? [:]
                    updatedInfo[MPMediaItemPropertyArtwork] = artwork
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = updatedInfo
                }
            }
        }

        // Update the now playing info
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    private func updateNowPlayingInfoPlaybackTime() {
        guard var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo else {
            return
        }

        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    private func updateNowPlayingInfoPlaybackState() {
        guard var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo else {
            return
        }

        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = state == .playing ? 1.0 :
            0.0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    private func loadArtwork(
        from url: URL,
        completion: @escaping (MPMediaItemArtwork?) -> Void
    ) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data, error == nil, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            let artwork = MPMediaItemArtwork(
                boundsSize: image.size
            ) { _ in image }

            DispatchQueue.main.async {
                completion(artwork)
            }
        }.resume()
    }

    private func setupNotifications() {
        // Handle interruptions (phone calls, etc.)
        NotificationCenter.default.publisher(
            for: AVAudioSession.interruptionNotification
        )
        .sink { [weak self] notification in
            guard let self,
                  let userInfo = notification.userInfo,
                  let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: typeValue) else
            {
                return
            }

            switch type {
            case .began:
                pausePlayback()
            case .ended:
                if let optionsValue =
                    userInfo[AVAudioSessionInterruptionOptionKey] as? UInt,
                    AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                    .contains(.shouldResume)
                {
                    resumePlayback()
                }
            @unknown default:
                break
            }
        }
        .store(in: &cancellables)

        // Handle playback completion
        NotificationCenter.default.publisher(
            for: .AVPlayerItemDidPlayToEndTime
        )
        .sink { [weak self] _ in
            guard let self else {
                return
            }

            currentTime = duration
            progress = 1.0
            state = .idle
        }
        .store(in: &cancellables)
    }

    private func cleanupPlayer() {
        if let timeObserver, let player {
            player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }

        player?.pause()
        player = nil
    }
}
