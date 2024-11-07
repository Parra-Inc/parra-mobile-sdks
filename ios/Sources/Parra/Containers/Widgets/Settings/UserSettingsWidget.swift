//
//  UserSettingsWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 10/29/24.
//

import SwiftUI

struct UserSettingsWidget: ParraContainer {
    // MARK: - Lifecycle

    init(
        config: ParraUserSettingsConfiguration,
        contentObserver: ContentObserver
    ) {
        self.config = config
        self._contentObserver = State(wrappedValue: contentObserver)
    }

    // MARK: - Internal

    @State var contentObserver: ContentObserver
    let config: ParraUserSettingsConfiguration

    @ViewBuilder
    @MainActor var body: some View {
        switch contentObserver.loadState {
        case .initial, .loading:
            VStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .background(
                parraTheme.palette.secondaryBackground.toParraColor()
            )
            .task { @MainActor in
                if contentObserver.loadState == .initial {
                    await contentObserver.loadSettingsLayout()
                }
            }
        case .loaded(let layout):
            ParraUserSettingsView(layout: layout) { key, value in
                onValueChanged(for: key, value)
            }
        default:
            EmptyView()
        }
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var parraTheme

    private func onValueChanged(
        for key: String,
        _ value: ParraSettingsItemDataWithValue
    ) {
        Task {
            do {
                try await contentObserver.updateSetting(
                    with: key,
                    to: value
                )

            } catch {}
        }
    }
}

#Preview {
    ParraContainerPreview<UserSettingsWidget>(config: .default) { parra, _, config in
        UserSettingsWidget(
            config: config,
            contentObserver: .init(
                initialParams: UserSettingsWidget.ContentObserver.InitialParams(
                    layoutId: "default",
                    layout: ParraUserSettingsLayout.validStates()[0],
                    config: config,
                    api: parra.parraInternal.api
                )
            )
        )
    }
}
