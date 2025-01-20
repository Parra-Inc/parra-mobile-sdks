//
//  Date+timeAgo.swift
//  Parra
//
//  Created by Mick MacCallum on 3/6/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

private let day: TimeInterval = 60 * 60 * 24

extension Date {
    func timeAgo(
        context: Formatter.Context = .standalone,
        dateTimeStyle: RelativeDateTimeFormatter.DateTimeStyle = .named,
        unitStyle: RelativeDateTimeFormatter.UnitsStyle = .full
    ) -> String {
        let now = Date()

        if timeIntervalSince(now) >= -2 {
            return "just now"
        }

        let formatter = RelativeDateTimeFormatter()

        formatter.formattingContext = context
        formatter.dateTimeStyle = dateTimeStyle
        formatter.unitsStyle = unitStyle

        return formatter.localizedString(
            for: self,
            relativeTo: now
        )
    }

    func timeAgoAbbreviated() -> String {
        let now = Date()

        if timeIntervalSince(now) >= -2 {
            return "now"
        }

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1

        return formatter.string(
            from: self,
            to: now
        ) ?? timeAgo(dateTimeStyle: .named, unitStyle: .abbreviated)
    }

    func daysAgo(_ daysAgo: TimeInterval) -> Date {
        return addingTimeInterval(-(day * daysAgo))
    }

    func daysFromNow(_ daysAgo: TimeInterval) -> Date {
        return self.daysAgo(-daysAgo)
    }
}

extension Date {
    func timeFromNowDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
