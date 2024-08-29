//
//  Sheet.swift
//  Parra
//
//  Created by Mick MacCallum on 3/25/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

@MainActor
struct Sheet<SheetContent>: ViewModifier where SheetContent: View {
    // MARK: - Lifecycle

    init(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> SheetContent,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) {
        _isPresented = isPresented
        self.content = content
        self.onDismiss = onDismiss
    }

    // MARK: - Internal

    @Binding var isPresented: Bool
    @ViewBuilder let content: () -> SheetContent

    func body(content: Content) -> some View {
        content.sheet(
            isPresented: $isPresented,
            onDismiss: {
                onDismiss?(.cancelled)
            },
            content: self.content
        )
    }

    // MARK: - Private

    private let onDismiss: ((ParraSheetDismissType) -> Void)?
}
