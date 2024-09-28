//
//  FeedCell.swift
//  ParraDev
//
//  Created by Mick MacCallum on 9/27/24.
//

import Parra
import SwiftUI

/// This example shows how you can perform a sheet presentation of the
/// ``ParraFeedView`` component. This feature is currently experimental!
struct FeedCell: View {
    @Environment(\.parra) private var parra
    @Environment(\.parraAppInfo) private var parraAppInfo

    @State private var isPresented = false

    var body: some View {
        Button(action: {
            isPresented = true
        }) {
            Label(
                title: {
                    Text("Social Feed")
                        .foregroundStyle(Color.primary)
                },
                icon: {
                    if isPresented {
                        ProgressView()
                    } else {
                        Image(systemName: "megaphone")
                    }
                }
            )
        }
        .disabled(isPresented)
        .presentParraFeedWidget(by: "home", isPresented: $isPresented)
    }
}

#Preview {
    ParraAppPreview {
        FeedbackCell()
    }
}
