//
//  CodeEntryView.swift
//  Parra
//
//  Created by Mick MacCallum on 5/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct CodeEntryView: View {
    // MARK: - Lifecycle

    public init(
        length: Int = 6,
        onChange: @escaping (String) -> Void,
        onComplete: @escaping (String) -> Void
    ) {
        self.length = length
        self.onChange = onChange
        self.onComplete = onComplete
    }

    // MARK: - Public

    public var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ForEach(0 ... length - 1, id: \.self) { index in
                makeDigitBox(index)
            }
        }
        .background {
            TextField("", text: $otpText.limit(length))
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .textCase(.uppercase)
                .autocorrectionDisabled()
                .frame(width: 1, height: 1)
                .opacity(0.00001)
                .blendMode(.screen)
                .focused($isKeyboardShowing)
                .onChange(of: otpText) { _, newValue in
                    onChange(newValue)

                    if newValue.count == length {
                        onComplete(newValue)
                    }
                }
                .onAppear {
                    DispatchQueue.main.async {
                        isKeyboardShowing = true
                    }
                }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isKeyboardShowing = true
        }
    }

    // MARK: - Internal

    @ViewBuilder
    func makeDigitBox(_ index: Int) -> some View {
        let palette = themeObserver.theme.palette

        ZStack {
            if otpText.count > index {
                let index = otpText.index(
                    otpText.startIndex,
                    offsetBy: index
                )

                Text(String(otpText[index]))
            } else {
                Text(" ")
            }
        }
        .frame(width: 42, height: 50)
        .background {
            let isHighlighted = isKeyboardShowing && otpText.count == index

            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(
                    isHighlighted
                        ? palette.primary.toParraColor()
                        : palette.primarySeparator.toParraColor()
                )
                .animation(
                    .easeOut(duration: 0.15),
                    value: isHighlighted
                )
        }
    }

    // MARK: - Private

    private let onChange: (String) -> Void
    private let onComplete: (String) -> Void
    private let length: Int

    @State private var otpText = ""
    @FocusState private var isKeyboardShowing: Bool

    @EnvironmentObject private var themeObserver: ParraThemeObserver
}

extension Binding where Value == String {
    func limit(_ length: Int) -> Self {
        if wrappedValue.count > length {
            DispatchQueue.main.async {
                wrappedValue = String(wrappedValue.prefix(length))
            }
        }

        return self
    }
}

#Preview {
    ParraViewPreview { _ in
        CodeEntryView { _ in

        } onComplete: { _ in
        }
    }
}
