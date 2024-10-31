//
//  ParraUserSettingsView.swift
//  Parra
//
//  Created by Mick MacCallum on 10/29/24.
//

import SwiftUI

struct UserSettingsItemInfoView: View {
    let item: ParraUserSettingsItem

    var body: some View {
        VStack(alignment: .leading) {
            Text(item.title)
                .lineLimit(1)

            withContent(content: item.description) { content in
                Text(content)
                    .font(.subheadline)
                    .lineLimit(3)
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .layoutPriority(10)
    }
}

struct UserSettingsBoolItemView: View {
    let item: ParraUserSettingsItem
    let value: ParraSettingsItemBooleanDataWithValue

    @State var toggleValue: Bool = false

    var body: some View {
        HStack {
            UserSettingsItemInfoView(item: item)

            Toggle(isOn: $toggleValue) {
                EmptyView()
            }
        }
    }
}

struct UserSettingsIntItemView: View {
    // MARK: - Lifecycle

    init(
        item: ParraUserSettingsItem,
        value: ParraSettingsItemIntegerDataWithValue
    ) {
        self.item = item
        self.value = value
        self._currentValue = State(
            initialValue: value.defaultValue ?? value.minValue ?? 1
        )
    }

    // MARK: - Internal

    let item: ParraUserSettingsItem
    let value: ParraSettingsItemIntegerDataWithValue

    @State var currentValue: Int

    var body: some View {
        HStack {
            UserSettingsItemInfoView(item: item)

            ParraStepper(
                value: $currentValue,
                minQuantity: value.minValue,
                maxQuantity: value.maxValue
            )
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}

struct UserSettingsStringItemView: View {
    // MARK: - Lifecycle

    init(
        item: ParraUserSettingsItem,
        value: ParraSettingsItemStringDataWithValue
    ) {
        self.item = item
        self.value = value
        self._currentValue = State(
            initialValue: value.value ?? value.defaultValue ?? ""
        )
    }

    // MARK: - Internal

    let item: ParraUserSettingsItem
    let value: ParraSettingsItemStringDataWithValue

    @State var currentValue: String

    var body: some View {
        HStack {
            UserSettingsItemInfoView(item: item)

            TextField(text: $currentValue) {}
                .frame(
                    width: 80
                )
        }
    }
}

struct ParraUserSettingsGroupView<Footer>: View where Footer: View {
    let group: ParraUserSettingsGroup
    @ViewBuilder let footer: () -> Footer

    var body: some View {
        Section {
            ForEach(group.items) { item in
                switch item.data {
                case .settingsItemBooleanDataWithValue(let value):
                    UserSettingsBoolItemView(
                        item: item,
                        value: value
                    )
                case .settingsItemIntegerDataWithValue(let value):
                    UserSettingsIntItemView(
                        item: item,
                        value: value
                    )
                case .settingsItemStringDataWithValue(let value):
                    UserSettingsStringItemView(
                        item: item,
                        value: value
                    )
                }
            }
        } header: {
            VStack(alignment: .leading) {
                Text(group.title)

                withContent(content: group.description) { content in
                    Text(content)
                        .font(.subheadline)
                }
            }
        } footer: {
            footer()
        }
        .headerProminence(.increased)
    }
}

struct ParraUserSettingsView: View {
    // MARK: - Internal

    @State var layout: ParraUserSettingsLayout

    var body: some View {
        VStack {
            withContent(content: layout.description) { content in
                componentFactory.buildLabel(
                    text: content,
                    localAttributes: .default(with: .subheadline)
                )
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .safeAreaPadding(.horizontal)
                .padding(.bottom, 16)
            }

            Form {
                ForEach(
                    Array(layout.groups.enumerated()),
                    id: \.element
                ) { index, group in
                    ParraUserSettingsGroupView(group: group) {
                        if index == layout.groups.count - 1 {
                            withContent(content: layout.footerLabel) { content in
                                componentFactory.buildLabel(
                                    text: content,
                                    localAttributes: .default(with: .footnote)
                                )
                            }
                        }
                    }
                }
            }
            .formStyle(.grouped)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle(layout.title)
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
}

#Preview {
    ParraViewPreview { _ in
        NavigationStack {
            ParraUserSettingsView(
                layout: .validStates()[0]
            )
        }
    }
}
