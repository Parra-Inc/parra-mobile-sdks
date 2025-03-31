//
//  NotificationSettingsCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 03/31/2025.
//  Copyright © 2025 Parra Inc.. All rights reserved.
//

import SwiftUI
import Parra

struct NotificationSettingsCell: View {
    @State private var presentationState: ParraSheetPresentationState = .ready

    var body: some View {
        ListItemLoadingButton(
            presentationState: $presentationState,
            text: "Notification settings",
            symbol: "bell.badge"
        )
        // Settings view layout IDs can be either the ID or Key for a group of
        // settings definied at https://parra.io/dashboard/users/configuration
        .presentParraNotificationSettingsView(
            presentationState: $presentationState
        )
    }
}
