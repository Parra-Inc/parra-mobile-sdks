//
//  Date+timeAgo.swift
//  Parra
//
//  Created by Mick MacCallum on 3/6/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension Date {
    func timeAgo(
        context: Formatter.Context = .standalone,
        dateTimeStyle: RelativeDateTimeFormatter.DateTimeStyle = .named,
        unitStyle: RelativeDateTimeFormatter.UnitsStyle = .full
    ) -> String {
        let formatter = RelativeDateTimeFormatter()

        formatter.formattingContext = context
        formatter.dateTimeStyle = dateTimeStyle
        formatter.unitsStyle = unitStyle

        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
