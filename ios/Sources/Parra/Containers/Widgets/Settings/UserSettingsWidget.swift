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

    var body: some View {
        content
            .environment(contentObserver)
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var parraTheme

    @ViewBuilder private var content: some View {
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
            .task {
                if contentObserver.loadState == .initial {
                    await contentObserver.loadSettingsLayout()
                }
            }
        case .loaded(let layout):
            ParraUserSettingsView(layout: layout)
                .equatable()
        default:
            EmptyView()
        }
    }
}
