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
        debounceDelay: TimeInterval = 3.0
    ) {
        self.item = item
        self.debounceDelay = debounceDelay
    }

    // MARK: - Internal

    let item: ParraUserSettingsItem
    let debounceDelay: TimeInterval

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

    // MARK: - Private

    @Environment(UserSettingsWidget.ContentObserver.self) private var contentObserver

    private func onValueChanged(
        _ value: ParraSettingsItemDataWithValue
    ) {
        Task {
            do {
                try await contentObserver.updateSetting(
                    with: item.key,
                    to: value
                )

            } catch {}
        }
    }
}
