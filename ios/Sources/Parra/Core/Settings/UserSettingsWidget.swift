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
        self._contentObserver = StateObject(wrappedValue: contentObserver)
    }

    // MARK: - Internal

    @StateObject var contentObserver: ContentObserver
    let config: ParraUserSettingsConfiguration

    var body: some View {
        content
    }

    // MARK: - Private

    @ViewBuilder private var content: some View {
        switch contentObserver.loadState {
        case .initial, .loading:
            VStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .task {
                if contentObserver.loadState == .initial {
                    await contentObserver.loadSettingsLayout()
                }
            }
        case .loaded(let layout):
            ParraUserSettingsView(layout: layout)
        default:
            EmptyView()
        }
    }
}
