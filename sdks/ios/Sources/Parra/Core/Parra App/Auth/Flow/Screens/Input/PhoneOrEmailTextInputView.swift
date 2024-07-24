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

struct PhoneOrEmailTextInputView: View {
    // MARK: - Lifecycle

    init(
        entry: Binding<String>,
        isFocused: FocusState<Bool>.Binding,
        mode: Mode = .auto,
        currendMode: Binding<Mode>,
        country: CountryCode = .usa,
        attributes: ParraAttributes.TextInput? = nil,
        onSubmit: (() -> Void)? = nil
    ) {
        self._entry = entry
        self.isFocused = isFocused
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
            from: themeManager.theme
        )
        .animation(.easeInOut(duration: 0.6), value: isFocused.wrappedValue)
        .sheet(
            isPresented: $presentSheet,
            onDismiss: {
                isFocused.wrappedValue = true
            }
        ) {
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
                            text: country.dialCode,
                            localAttributes: .init(
                                text: .init(
                                    color: themeManager.theme.palette
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
            .presentationDetents([.large])
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
                    || country.dialCode.hasSuffix(comp)
            }
        }
    }

    var fieldBackgroundColor: Color {
        return themeManager.theme.palette.secondaryBackground
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

    private var isFocused: FocusState<Bool>.Binding

    @EnvironmentObject private var themeManager: ParraThemeManager
    @EnvironmentObject private var componentFactory: ComponentFactory

    @ViewBuilder private var textField: some View {
        let keyboardType: UIKeyboardType = switch defaultMode {
        case .phone:
            .phonePad
        case .email:
            .emailAddress
        case .auto:
            .emailAddress
        }

        let contentType: UITextContentType? = switch currentMode {
        case .phone:
            .telephoneNumber
        // Should be username even for email case for autofill reasons.
        case .email:
            .username
        case .auto:
            .username
        }

        let placeholder = switch defaultMode {
        case .phone:
            "Phone number"
        case .email:
            "Email address"
        case .auto:
            "Email or phone number"
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
                        .trimmingPrefix(selectedCountry.dialCode)

                    return String(val)
                },
                set: { val in
                    if currentMode == .phone {
                        entry = (selectedCountry.dialCode + val)
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
        .overlay {
            if !entry.isEmpty {
                HStack {
                    Spacer()

                    Button {
                        entry = ""
                    } label: {
                        Image(systemName: "multiply.circle.fill")
                    }
                    .foregroundColor(.secondary.opacity(0.8))
                    .padding(.trailing, 3)
                }
            }
        }
        .focused(isFocused)
        .keyboardType(keyboardType)
        .autocorrectionDisabled(true)
        .textContentType(contentType)
        .textInputAutocapitalization(.never)
    }

    @ViewBuilder private var content: some View {
        let textInputAttributes = componentFactory.attributeProvider
            .textInputAttributes(
                config: .default,
                localAttributes: attributes,
                theme: themeManager.theme
            )

        if currentMode == .phone {
            Button {
                presentSheet = true
                isFocused.wrappedValue = false
            } label: {
                Text("\(selectedCountry.flag) \(selectedCountry.code)")
                    .frame(minWidth: 56)
            }
            .applyTextInputAttributes(
                textInputAttributes,
                using: themeManager.theme
            )
        }

        textField
            .applyTextInputAttributes(
                textInputAttributes,
                using: themeManager.theme
            )
            .onChange(of: selectedCountry) { oldValue, _ in
                entry.trimPrefix(oldValue.dialCode)
            }
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
