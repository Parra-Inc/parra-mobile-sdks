//
//  AdminMenuView.swift
//  Parra
//
//  Created by Mick MacCallum on 2/24/25.
//

import SwiftUI

struct AdminMenuView: View {
    @Binding var isConfirmingLock: Bool
    @Binding var isConfirmingUnlock: Bool
    @Binding var isConfirmingLeave: Bool
    @Binding var isConfirmingArchive: Bool

    @StateObject var contentObserver: ChannelWidget.ContentObserver

    var body: some View {
        Menu("Admin Menu", systemImage: "ellipsis.circle") {
            Section("Admin Menu") {
                if contentObserver.channel.status == .active {
                    Button("Lock", systemImage: "lock") {
                        isConfirmingLock = true
                    }
                } else {
                    Button("Unlock", systemImage: "lock.open") {
                        isConfirmingUnlock = true
                    }
                }

                Button("Leave", systemImage: "rectangle.portrait.and.arrow.right") {
                    isConfirmingLeave = true
                }

                Button("Archive", systemImage: "archivebox") {
                    isConfirmingArchive = true
                }
            }
        }
        .menuStyle(.button)
    }
}
