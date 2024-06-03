//
//  PhoneOrEmailTextInputView.swift
//  Parra
//
//  Created by Mick MacCallum on 5/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Combine
import SwiftUI

// Need to make the external binding reflect a final phone number or email
// Keep internal copy of state and mirror externally, removing phone number
// formatting and adding county code prefix

class PhoneNumberFormatter: Formatter {
    // MARK: - Lifecycle

    required init(
        pattern: String,
        replacementCharacter: Character = "#",
        enabled: Bool = true
    ) {
        self.pattern = pattern
        self.replacementCharacter = replacementCharacter
        self.enabled = enabled

        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal

    let pattern: String
    let replacementCharacter: Character
    let enabled: Bool

    override func string(for obj: Any?) -> String? {
        guard let value = obj as? String else {
            return nil
        }

        guard enabled else {
            return value
        }

        return applyPhoneNumberPattern(
            on: value
        )
    }

    override func getObjectValue(
        _ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
        for string: String,
        errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?
    ) -> Bool {
        obj?.pointee = string as NSString
        return true
    }

    func applyPhoneNumberPattern(
        on input: String
    ) -> String {
        var pureNumber = input.replacingOccurrences(
            of: "[^0-9\\+]",
            with: "",
            options: .regularExpression
        )

        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else {
                return pureNumber
            }

            let stringIndex = String.Index(utf16Offset: index, in: pattern)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacementCharacter else {
                continue
            }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }

        return pureNumber
    }
}

struct PhoneOrEmailTextInputView: View {
    // MARK: - Lifecycle

    init(
        entry: Binding<String>,
        mode: Mode = .auto,
        currendMode: Binding<Mode>,
        country: CountryCode = .usa,
        attributes: ParraAttributes.TextInput? = nil,
        onSubmit: (() -> Void)? = nil
    ) {
        self._entry = entry
        self._currentMode = currendMode

        self.defaultMode = mode
        self.selectedCountry = country
        self.attributes = attributes
        self.onSubmit = onSubmit
    }

    // MARK: - Internal

    var body: some View {
        HStack {
            content
        }
        .applyPadding(
            size: .md,
            from: themeObserver.theme
        )
        .animation(.easeInOut(duration: 0.6), value: keyIsFocused)
        .onTapGesture {
            let resign = #selector(UIResponder.resignFirstResponder)

            UIApplication.shared.sendAction(
                resign,
                to: nil,
                from: nil,
                for: nil
            )
        }
        .sheet(isPresented: $presentSheet) {
            NavigationView {
                List(filteredResorts) { country in
                    HStack {
                        Text(country.flag)

                        componentFactory.buildLabel(
                            text: country.name,
                            localAttributes: .default(with: .headline)
                        )

                        Spacer()

                        componentFactory.buildLabel(
                            text: country.dial_code,
                            localAttributes: .init(
                                text: .init(
                                    color: themeObserver.theme.palette
                                        .secondaryText.toParraColor()
                                )
                            )
                        )
                    }
                    .onTapGesture {
                        selectedCountry = country
                        presentSheet = false
                        searchCountry = ""
                    }
                }
                .listStyle(.plain)
                .searchable(
                    text: $searchCountry,
                    placement: .navigationBarDrawer(
                        displayMode: .always
                    ),
                    prompt: "Search"
                )
            }
            .presentationDetents([.medium, .large])
        }
    }

    var filteredResorts: [CountryCode] {
        let countries = CountryCode.allCountries

        if searchCountry.isEmpty {
            return countries
        } else {
            return countries.filter { country in
                let comp = searchCountry.lowercased()

                return country.name.lowercased().contains(comp)
                    || country.code.lowercased() == comp
                    || country.dial_code.hasSuffix(comp)
            }
        }
    }

    var fieldBackgroundColor: Color {
        return themeObserver.theme.palette.secondaryBackground
    }

    // MARK: - Private

    private let attributes: ParraAttributes.TextInput?

    private let defaultMode: Mode
    private let onSubmit: (() -> Void)?
    @Binding private var currentMode: Mode
    @State private var presentSheet = false
    @State private var selectedCountry: CountryCode
    @Binding private var entry: String
    @State private var searchCountry: String = ""

    @FocusState private var keyIsFocused: Bool

    @EnvironmentObject private var themeObserver: ParraThemeObserver
    @EnvironmentObject private var componentFactory: ComponentFactory

    @ViewBuilder private var content: some View {
        let keyboardType: UIKeyboardType = switch defaultMode {
        case .phone:
            .phonePad
        case .email:
            .emailAddress
        case .auto:
            .default
        }

        let contentType: UITextContentType? = switch currentMode {
        case .phone:
            .telephoneNumber
        case .email:
            .emailAddress
        case .auto:
            nil
        }

        let placeholder = switch defaultMode {
        case .phone:
            "Phone number"
        case .email:
            "Email"
        case .auto:
            "Email or phone number"
        }

        let textInputAttributes = componentFactory.attributeProvider
            .textInputAttributes(
                config: .default,
                localAttributes: attributes,
                theme: themeObserver.theme
            )

        if currentMode == .phone {
            Button {
                presentSheet = true
                keyIsFocused = false
            } label: {
                Text("\(selectedCountry.flag) \(selectedCountry.code)")
                    .frame(minWidth: 56)
            }
            .applyTextInputAttributes(
                textInputAttributes,
                using: themeObserver.theme
            )
        }

        TextField(
            value: Binding<String>(
                get: {
                    // We trim the dial code from the entry in the email case
                    // too, in case there was a transition from phone to email
                    // that caused it to remain.
                    let val = $entry.wrappedValue
                        .trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )
                        .trimmingPrefix(selectedCountry.dial_code)

                    return String(val)
                },
                set: { val in
                    if currentMode == .phone {
                        entry = (selectedCountry.dial_code + val)
                            .replacingOccurrences(of: " ", with: "")
                    } else {
                        entry = val.replacingOccurrences(of: " ", with: "")
                    }
                }
            ),
            formatter: PhoneNumberFormatter(
                pattern: selectedCountry.pattern,
                enabled: currentMode == .phone
            ),
            prompt: Text(placeholder)
                .foregroundColor(.secondary)

        ) {
            EmptyView()
        }
        .focused($keyIsFocused)
        .keyboardType(keyboardType)
        .autocorrectionDisabled(true)
        .textContentType(contentType)
        .textInputAutocapitalization(.never)
        .applyTextInputAttributes(
            textInputAttributes,
            using: themeObserver.theme
        )
        .onChange(of: entry) { _, newValue in
            // If the mode isn't auto, don't change it
            guard defaultMode == .auto else {
                return
            }

            let trimmed = newValue.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

            // Let the user enter a few characters before potentially
            // changing the UI
            guard trimmed.count >= 3 else {
                // If the text input is cleared, we have to reset which
                // mode it was last known to be in.
                if trimmed.isEmpty {
                    withAnimation(.snappy) {
                        currentMode = .auto
                    }
                }

                return
            }

            withAnimation(.snappy) {
                currentMode = trimmed.matches(
                    pattern: /^.*[a-zA-Z]+.*$/
                ) ? .email : .phone
            }
        }
        .onSubmit(of: .text) {
            onSubmit?()
        }
    }
}

#Preview {
    ParraViewPreview { _ in
        PhoneOrEmailTextInputView(
            entry: .constant(""),
            currendMode: .constant(.auto)
        )
    }
}
