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
        detents: Set<PresentationDetent> = [.large],
        visibility: Visibility = .visible,
        onDismiss: ((SheetDismissType) -> Void)? = nil
    ) {
        _isPresented = isPresented
        self.content = content
        self.detents = detents
        self.visibility = visibility
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
            content: {
                NavigationStack(path: $navigationState.navigationPath) {
                    self.content()
                        .environmentObject(navigationState)
                        .padding(.top, 30)
                }
                .presentationDetents(detents)
                .presentationDragIndicator(visibility)
                .navigationBarTitleDisplayMode(.inline)
            }
        )
    }

    // MARK: - Private

    @StateObject private var navigationState = NavigationState()

    private let detents: Set<PresentationDetent>
    private let visibility: Visibility
    private let onDismiss: ((SheetDismissType) -> Void)?
}
