//
//  UserSettingsBoolItemView.swift
//  Parra
//
//  Created by Mick MacCallum on 10/31/24.
//

import SwiftUI

private let finalDefaultValue = false

struct UserSettingsBoolItemView: View {
    // MARK: - Lifecycle

    init(
        item: ParraUserSettingsItem,
        value: ParraSettingsItemBooleanDataWithValue,
        onValueChange: @escaping (ParraSettingsItemBooleanDataWithValue) -> Void
    ) {
        self.item = item
        self.value = value
        self.onValueChange = onValueChange
        self._currentValue = State(
            initialValue: value.value ?? value.defaultValue ?? finalDefaultValue
        )
    }

    // MARK: - Internal

    let item: ParraUserSettingsItem
    let value: ParraSettingsItemBooleanDataWithValue
    let onValueChange: (ParraSettingsItemBooleanDataWithValue) -> Void

    @State var currentValue: Bool = finalDefaultValue

    var body: some View {
        HStack {
            UserSettingsItemInfoView(item: item)

            Toggle(isOn: $currentValue) {
                EmptyView()
            }
            .tint(theme.palette.primary.toParraColor())
        }
        .onChange(of: currentValue) { _, newValue in
            onValueChange(
                ParraSettingsItemBooleanDataWithValue(
                    format: value.format,
                    trueLabel: value.trueLabel,
                    falseLabel: value.falseLabel,
                    defaultValue: value.defaultValue,
                    value: newValue
                )
            )
        }
    }

    // MARK: - Private

    @Environment(\.parraUserSettings) private var settings
    @Environment(\.parraTheme) private var theme
}
