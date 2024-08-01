//
//  View+Sheet.swift
//  Parra
//
//  Created by Mick MacCallum on 3/25/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension View {
    @MainActor
    func presentSheet(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> some View,
        onDismiss: ((SheetDismissType) -> Void)? = nil
    ) -> some View {
        modifier(
            Sheet(
                isPresented: isPresented,
                content: content,
                onDismiss: onDismiss
            )
        )
    }
}
