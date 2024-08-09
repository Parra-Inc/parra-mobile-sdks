//
//  AppReleaseSection+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 3/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let fakeBugs = [
    "Resolved an issue where the app would crash on launch for some iOS devices.",
    "Fixed a bug causing incorrect display of dates in the calendar view.",
    "Corrected a problem with push notifications not being delivered on Android 11.",
    "Addressed an issue where the app would freeze during video playback.",
    "Fixed a bug that prevented users from saving their progress in tutorials.",
    "Resolved an error where user settings would reset after the app was closed.",
    "Corrected a typo in the privacy policy section.",
    "Fixed a bug where the app would consume excessive battery in the background.",
    "Addressed an issue causing slow app startup times on older devices.",
    "Resolved a problem with the search function returning incorrect results.",
    "Fixed a UI glitch that occurred when changing screen orientation.",
    "Corrected an issue where the app would fail to sync data under certain network conditions.",
    "Fixed a bug that prevented the loading of user profiles in offline mode.",
    "Addressed a graphical glitch in the menu on high-resolution screens.",
    "Resolved an issue where external links would not open in the app's browser."
]

private let fakeFeatures = [
    "Introduced Dark Mode for a more comfortable viewing experience at night.",
    "Added multi-language support, including Spanish, French, and German.",
    "New user profiles feature allowing customization and personalization.",
    "Integrated a new payment system for in-app purchases and subscriptions.",
    "Launched a community forum within the app for user discussions and feedback.",
    "Introduced live chat support for real-time assistance.",
    "Added an in-app tutorial for new users to navigate through the app features.",
    "New fitness tracking features with integration to Apple Health and Google Fit.",
    "Implemented voice commands for hands-free navigation within the app.",
    "Added the ability to schedule posts and activities within the app.",
    "Introduced a new photo editing tool with filters and stickers.",
    "New AR (Augmented Reality) features for enhanced user interaction.",
    "Integrated social media sharing directly from the app.",
    "Added a feature for custom reminders and notifications.",
    "Launched a new game section for user engagement and retention."
]

private let fakeEnhancements = [
    "Improved app loading times by optimizing backend processes.",
    "Enhanced user interface for better navigation and usability.",
    "Upgraded encryption protocols for enhanced data security.",
    "Refined the push notification system for more relevant alerts.",
    "Streamlined the in-app purchase process for quicker transactions.",
    "Optimized app performance for devices with lower RAM.",
    "Enhanced the video playback quality and reduced buffering times.",
    "Improved search algorithm for more accurate and relevant results.",
    "Updated the design of user profiles for a more modern look.",
    "Enhanced the data sync feature for faster and more reliable performance.",
    "Improved battery usage for longer app sessions without charging.",
    "Refined user feedback collection for better app development focus.",
    "Enhanced the FAQ and help sections for quicker problem resolution.",
    "Improved the accuracy of fitness tracking features.",
    "Enhanced social media integration for smoother sharing and engagement."
]

// MARK: - ParraAppReleaseSection + ParraFixture

extension ParraAppReleaseSection: ParraFixture {
    static func validStates() -> [ParraAppReleaseSection] {
        let features = fakeFeatures.shuffled().prefix(Int.random(in: 1 ... 5))
        let bugs = fakeBugs.shuffled().prefix(Int.random(in: 1 ... 5))
        let enhancements = fakeEnhancements.shuffled()
            .prefix(Int.random(in: 1 ... 5))

        return [
            ParraAppReleaseSection(
                id: "features",
                title: "✨ Features",
                items: features.map {
                    createAppReleaseItem(with: $0)
                }
            ),
            ParraAppReleaseSection(
                id: "bugfixes",
                title: "🐛 Bug Fixes",
                items: bugs.map {
                    createAppReleaseItem(with: $0)
                }
            ),
            ParraAppReleaseSection(
                id: "enhancements",
                title: "🔧 Enhancements",
                items: enhancements.map {
                    createAppReleaseItem(with: $0)
                }
            )
        ]
    }

    static func invalidStates() -> [ParraAppReleaseSection] {
        return []
    }

    private static func createAppReleaseItem(with title: String)
        -> ParraAppReleaseItem
    {
        let createdAt = Date.now
            .daysAgo(TimeInterval(Int.random(in: 1 ... 100)))
        let ticketId = UUID().uuidString
        let tenantId = UUID().uuidString

        let icon: ParraTicketIcon? = if let emoji = String.randomEmoji() {
            ParraTicketIcon(
                type: .emoji,
                value: emoji
            )
        } else {
            nil
        }

        return ParraAppReleaseItem(
            id: UUID().uuidString,
            createdAt: createdAt,
            updatedAt: createdAt
                .addingTimeInterval(TimeInterval(Int.random(in: 0 ... 10_000))),
            deletedAt: nil,
            releaseId: UUID().uuidString,
            ticketId: ticketId,
            ticket: ParraTicketStub(
                id: ticketId,
                createdAt: .now,
                updatedAt: .now.daysAgo(1.3),
                deletedAt: nil,
                title: title,
                shortTitle: nil,
                type: ParraTicketType.allCases.randomElement()!,
                status: ParraTicketStatus.allCases.randomElement()!,
                priority: ParraTicketPriority.allCases.randomElement()!,
                description: nil,
                votingEnabled: true,
                isPublic: true,
                userNoteId: nil,
                estimatedStartDate: .now
                    .daysFromNow(TimeInterval(Int.random(in: 0 ... 100))),
                estimatedCompletionDate: .now
                    .daysFromNow(TimeInterval(Int.random(in: 0 ... 100))),
                icon: icon,
                ticketNumber: "PAR-2349",
                tenantId: tenantId,
                voteCount: Int.random(in: 0 ... 12_345),
                releasedAt: nil
            )
        )
    }
}
