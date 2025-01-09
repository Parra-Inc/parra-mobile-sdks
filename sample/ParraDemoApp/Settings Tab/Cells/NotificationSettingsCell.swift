//
//  NotificationSettingsCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 01/09/2025.
//  Copyright © 2025 Parra Inc.. All rights reserved.
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
        .presentParraSettingsView(
            layoutId: "notifications",
            isPresented: $isPresented
        )
    }
}
