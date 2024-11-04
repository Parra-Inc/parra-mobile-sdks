//
//  NotificationSettingsCell.swift
//  ParraDev
//
//  Created by Mick MacCallum on 10/29/24.
//

import SwiftUI
import Parra

struct NotificationSettingsCell: View {
    @State private var isPresented = false

    var body: some View {
        ListItemLoadingButton(
            isLoading: $isPresented,
            text: "Notifications",
            symbol: "bell.badge"
        )
        // Settings view layout IDs can be either the ID or Key for a group of
        // settings definied at https://parra.io/dashboard/users/configuration
        .presentParraSettingsView(
            layoutId: "notifications",
            isPresented: $isPresented
        )
    }
}
