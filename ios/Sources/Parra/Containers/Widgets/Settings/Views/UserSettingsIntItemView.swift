//
//  UserSettingsIntItemView.swift
//  Parra
//
//  Created by Mick MacCallum on 10/31/24.
//

import SwiftUI

struct UserSettingsIntItemView: View {
    // MARK: - Lifecycle

    init(
        item: ParraUserSettingsItem,
        value: ParraSettingsItemIntegerDataWithValue,
        onValueChange: @escaping (ParraSettingsItemIntegerDataWithValue) -> Void
    ) {
        self.item = item
        self.value = value
        self.onValueChange = onValueChange
        self._currentValue = State(
            initialValue: value.defaultValue ?? value.minValue ?? 1
        )
    }

    // MARK: - Internal

    let item: ParraUserSettingsItem
    let value: ParraSettingsItemIntegerDataWithValue
    let onValueChange: (ParraSettingsItemIntegerDataWithValue) -> Void

    @State var currentValue: Int

    var body: some View {
        HStack {
            UserSettingsItemInfoView(item: item)

            ParraStepper(
                value: $currentValue,
                minQuantity: value.minValue ?? 1,
                maxQuantity: value.maxValue ?? .max,
                step: 1
            )
            .buttonStyle(BorderlessButtonStyle())
        }
        .onChange(of: currentValue) { _, newValue in
            onValueChange(
                ParraSettingsItemIntegerDataWithValue(
                    defaultValue: value.defaultValue,
                    minValue: value.minValue,
                    maxValue: value.maxValue,
                    value: newValue
                )
            )
        }
    }
}
