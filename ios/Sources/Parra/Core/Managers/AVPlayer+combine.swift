//
//  AVPlayer+combine.swift
//  Parra
//
//  Created by Mick MacCallum on 5/28/25.
//

import AVFoundation
import Combine

extension AVPlayer {
    func periodicTimePublisher(
        forInterval interval: CMTime = CMTime(
            seconds: 0.5,
            preferredTimescale: CMTimeScale(NSEC_PER_SEC)
        )
    ) -> AnyPublisher<CMTime, Never> {
        Publisher(self, forInterval: interval)
            .eraseToAnyPublisher()
    }
}

// MARK: - AVPlayer.Publisher

private extension AVPlayer {
    private struct Publisher: Combine.Publisher {
        // MARK: - Lifecycle

        init(_ player: AVPlayer, forInterval interval: CMTime) {
            self.player = player
            self.interval = interval
        }

        // MARK: - Internal

        typealias Output = CMTime
        typealias Failure = Never

        var player: AVPlayer
        var interval: CMTime

        func receive<S>(subscriber: S) where S: Subscriber,
            Publisher.Failure == S.Failure,
            Publisher.Output == S.Input
        {
            let subscription = CMTime.Subscription(
                subscriber: subscriber,
                player: player,
                forInterval: interval
            )
            subscriber.receive(subscription: subscription)
        }
    }
}

// MARK: - CMTime.Subscription

private extension CMTime {
    final class Subscription<SubscriberType: Subscriber>: Combine.Subscription
        where SubscriberType.Input == CMTime, SubscriberType.Failure == Never
    {
        // MARK: - Lifecycle

        init(subscriber: SubscriberType, player: AVPlayer, forInterval interval: CMTime) {
            self.player = player
            self.observer = player.addPeriodicTimeObserver(
                forInterval: interval,
                queue: nil
            ) { time in
                _ = subscriber.receive(time)
            }
        }

        // MARK: - Internal

        var player: AVPlayer? = nil
        var observer: Any? = nil

        func request(_ demand: Subscribers.Demand) {
            // We do nothing here as we only want to send events when they occur.
            // See, for more info: https://developer.apple.com/documentation/combine/subscribers/demand
        }

        func cancel() {
            if let observer {
                player?.removeTimeObserver(observer)
            }

            observer = nil
            player = nil
        }
    }
}
