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
        disabled: Bool = false,
        onChange: @escaping (String) -> Void,
        onComplete: @escaping (String) -> Void
    ) {
        self.length = length
        self.disabled = disabled
        self.onChange = onChange
        self.onComplete = onComplete
    }

    // MARK: - Public

    public var body: some View {
        HStack(alignment: .center) {
            ForEach(0 ... length - 1, id: \.self) { index in
                makeDigitBox(index)

                if index < length - 1 {
                    Spacer()
                }
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
                .onChange(of: otpText, onOtpTextChanged)
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
        let isHighlighted = isKeyboardShowing && !disabled && otpText
            .count == index

        ZStack {
            if otpText.count > index {
                let index = otpText.index(
                    otpText.startIndex,
                    offsetBy: index
                )

                Text(String(otpText[index]))
            } else {
                if isHighlighted {
                    Text("|")
                        .font(.title3)
                        .fontWeight(.light)
                        .foregroundStyle(palette.primary)
                } else {
                    Text(" ")
                }
            }
        }
        .frame(width: 46, height: 60)
        .background {
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
    private let disabled: Bool

    @State private var otpText = ""
    @FocusState private var isKeyboardShowing: Bool

    @EnvironmentObject private var themeObserver: ParraThemeObserver

    private func onOtpTextChanged(
        oldValue: String,
        newValue: String
    ) {
        // When this is disabled, we still want to be able to
        // display the keyboard but just want to ignore any input.
        if disabled, newValue != "" {
            otpText = ""

            return
        }

        let next = String(newValue.unicodeScalars.filter(
            CharacterSet.decimalDigits.contains
        ))

        onChange(next)

        if next.count == length {
            onComplete(next)
        }

        if next != newValue {
            otpText = next
        }
    }
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
        .padding()
    }
}
