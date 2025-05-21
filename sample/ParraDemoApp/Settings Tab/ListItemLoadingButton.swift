//
//  ListItemLoadingButton.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 05/21/2025.
//  Copyright © 2025 Parra Inc.. All rights reserved.
//

import SwiftUI
import Parra

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
    @Binding var presentationState: ParraSheetPresentationState
    let text: String
    let symbol: String

    private var isLoading: Bool {
        return presentationState == .loading
    }

    var body: some View {
        Button {
            presentationState = .loading
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
