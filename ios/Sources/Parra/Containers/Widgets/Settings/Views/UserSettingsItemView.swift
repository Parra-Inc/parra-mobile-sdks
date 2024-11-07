//
//  UserSettingsItemView.swift
//  Parra
//
//  Created by Mick MacCallum on 10/31/24.
//

import Combine
import SwiftUI

struct UserSettingsItemView: View {
    // MARK: - Lifecycle

    init(
        item: ParraUserSettingsItem,
        debounceDelay: TimeInterval = 3.0,
        onValueChanged: @escaping (_ value: ParraSettingsItemDataWithValue) -> Void
    ) {
        self.item = item
        self.debounceDelay = debounceDelay
        self.onValueChanged = onValueChanged
    }

    // MARK: - Internal

    let item: ParraUserSettingsItem
    let debounceDelay: TimeInterval
    let onValueChanged: (_ value: ParraSettingsItemDataWithValue) -> Void

    var body: some View {
        switch item.data {
        case .settingsItemBooleanDataWithValue(let value):
            UserSettingsBoolItemView(
                item: item,
                value: value
            ) { updatedValue in
                onValueChanged(
                    .settingsItemBooleanDataWithValue(updatedValue)
                )
            }
        case .settingsItemIntegerDataWithValue(let value):
            UserSettingsIntItemView(
                item: item,
                value: value
            ) { updatedValue in
                onValueChanged(
                    .settingsItemIntegerDataWithValue(updatedValue)
                )
            }
        case .settingsItemStringDataWithValue(let value):
            UserSettingsStringItemView(
                item: item,
                value: value
            ) { updatedValue in
                onValueChanged(
                    .settingsItemStringDataWithValue(updatedValue)
                )
            }
        }
    }
}
