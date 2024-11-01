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
        .presentParraSettingsView(
            layoutId: "notifications",
            isPresented: $isPresented
        )
    }
}
