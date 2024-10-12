//
//  ParraDismissButton.swift
//  Parra
//
//  Created by Mick MacCallum on 10/12/24.
//

import SwiftUI

public struct ParraDismissButton: View {
    // MARK: - Lifecycle

    // Prevent default with environment values.
    public init() {}

    // MARK: - Public

    public var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            ZStack {
                Circle()
                    .fill(parraTheme.palette.secondaryBackground)
                    .frame(width: 30, height: 30)

                Image(systemName: "xmark")
                    .font(.system(
                        size: 12,
                        weight: .bold,
                        design: .rounded
                    ))
                    .foregroundColor(.secondary)
            }
            .contentShape(Circle())
        })
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(Text("Close"))
    }

    // MARK: - Private

    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.parraTheme) private var parraTheme
}
