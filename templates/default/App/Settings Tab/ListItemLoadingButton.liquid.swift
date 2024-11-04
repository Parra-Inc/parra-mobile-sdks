//
//  ListItemLoadingButton.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import SwiftUI

struct ListItemLabel: View {
    let text: String
    let symbol: String
    let isLoading: Bool

    init(
        text: String,
        symbol: String,
        isLoading: Bool = false
    ) {
        self.text = text
        self.symbol = symbol
        self.isLoading = isLoading
    }

    var body: some View {
        Label(
            title: {
                Text(text)
                    .foregroundStyle(Color.primary)
            },
            icon: {
                if isLoading {
                    ProgressView()
                } else {
                    Image(systemName: symbol)
                        .foregroundStyle(.tint)
                }
            }
        )
    }
}

struct ListItemLoadingButton: View {
    @Binding var isLoading: Bool
    let text: String
    let symbol: String

    var body: some View {
        Button {
            isLoading = true
        } label: {
            ListItemLabel(
                text: text,
                symbol: symbol,
                isLoading: isLoading
            )
        }
        .disabled(isLoading)
    }
}
