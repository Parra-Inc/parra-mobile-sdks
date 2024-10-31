//
//  UserSettingsStringItemView.swift
//  Parra
//
//  Created by Mick MacCallum on 10/31/24.
//

import SwiftUI

struct UserSettingsStringItemView: View {
    // MARK: - Lifecycle

    init(
        item: ParraUserSettingsItem,
        value: ParraSettingsItemStringDataWithValue,
        onValueChange: @escaping (ParraSettingsItemStringDataWithValue) -> Void
    ) {
        self.item = item
        self.value = value
        self.onValueChange = onValueChange
        self._currentValue = State(
            initialValue: value.value ?? value.defaultValue ?? ""
        )
    }

    // MARK: - Internal

    let item: ParraUserSettingsItem
    let value: ParraSettingsItemStringDataWithValue
    let onValueChange: (ParraSettingsItemStringDataWithValue) -> Void

    @State var currentValue: String

    var body: some View {
        HStack {
            UserSettingsItemInfoView(item: item)

            TextField(text: $currentValue) {}
                .frame(
                    width: 80
                )
        }
        .onChange(of: currentValue) { _, newValue in
            onValueChange(
                ParraSettingsItemStringDataWithValue(
                    format: value.format,
                    enumOptions: value.enumOptions,
                    defaultValue: value.defaultValue,
                    value: newValue
                )
            )
        }
    }
}
