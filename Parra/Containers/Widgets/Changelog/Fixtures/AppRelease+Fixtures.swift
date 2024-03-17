//
//  AppRelease+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 3/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

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

// MARK: - AppRelease + ParraFixture

extension AppRelease: ParraFixture {
    private static func createAppReleaseItem(with title: String)
        -> AppReleaseItem
    {
        let createdAt = Date.now
            .daysAgo(TimeInterval(Int.random(in: 1 ... 100)))
        let ticketId = UUID().uuidString
        let tenantId = UUID().uuidString

        return AppReleaseItem(
            id: UUID().uuidString,
            createdAt: createdAt,
            updatedAt: createdAt
                .addingTimeInterval(TimeInterval(Int.random(in: 0 ... 10_000))),
            deletedAt: nil,
            releaseId: UUID().uuidString,
            ticketId: ticketId,
            ticket: Ticket(
                id: ticketId,
                createdAt: .now,
                updatedAt: .now.daysAgo(1.3),
                deletedAt: nil,
                title: title,
                shortTitle: nil,
                type: TicketType.allCases.randomElement()!,
                status: TicketStatus.allCases.randomElement()!,
                priority: TicketPriority.allCases.randomElement()!,
                description: nil,
                votingEnabled: true,
                isPublic: true,
                userNoteId: nil,
                estimatedStartDate: .now
                    .daysFromNow(TimeInterval(Int.random(in: 0 ... 100))),
                estimatedCompletionDate: .now
                    .daysFromNow(TimeInterval(Int.random(in: 0 ... 100))),
                ticketNumber: "PAR-2349",
                tenantId: tenantId,
                voteCount: Int.random(in: 0 ... 12_345),
                releasedAt: nil,
                release: ReleaseStub(
                    id: UUID().uuidString,
                    createdAt: .now,
                    updatedAt: .now,
                    deletedAt: nil,
                    name: "idk",
                    version: "1.0.0",
                    description: nil,
                    type: ReleaseType.allCases.randomElement()!,
                    tenantId: tenantId,
                    releaseNumber: Int.random(in: 1 ... 100),
                    status: ReleaseStatus.allCases.randomElement()!
                )
            )
        )
    }

    private static func makeRandomReleaseSections() -> [AppReleaseSection] {
        let features = fakeFeatures.shuffled().prefix(Int.random(in: 0 ... 4))
        let bugs = fakeBugs.shuffled().prefix(Int.random(in: 0 ... 4))
        let enhancements = fakeEnhancements.shuffled()
            .prefix(Int.random(in: 0 ... 4))

        return [
            AppReleaseSection(
                title: "✨ Features",
                items: features.map {
                    createAppReleaseItem(with: $0)
                }
            ),
            AppReleaseSection(
                title: "🐛 Bug Fixes",
                items: bugs.map {
                    createAppReleaseItem(with: $0)
                }
            ),
            AppReleaseSection(
                title: "🔧 Enhancements",
                items: enhancements.map {
                    createAppReleaseItem(with: $0)
                }
            )
        ]
    }

    static func validStates() -> [AppRelease] {
        return AppReleaseStub.validStates().enumerated().map { _, element in
            return AppRelease(
                id: element.id,
                createdAt: element.createdAt,
                updatedAt: element.updatedAt,
                deletedAt: element.deletedAt,
                name: element.name,
                version: element.version,
                description: element.description,
                type: element.type,
                tenantId: element.tenantId,
                releaseNumber: element.releaseNumber,
                status: element.status,
                sections: makeRandomReleaseSections()
            )
        }
    }

    static func invalidStates() -> [AppRelease] {
        return []
    }
}
