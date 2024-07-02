//
//  ParraDefaultProfileView.swift
//  Parra
//
//  Created by Mick MacCallum on 4/30/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ProfileSettingsWidget: View {
    var body: some View {
        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text(
            "Hello, world!"
        )/*@END_MENU_TOKEN@*/
    }
}

public struct ParraDefaultProfileView: View {
    // MARK: - Lifecycle

    public init(
        config: ProfileWidgetConfig = .default
    ) {
        self.config = config
    }

    // MARK: - Public

    public var body: some View {
        NavigationStack {
            profileContainer
                .toolbar {
                    if config.settingsEnabled {
                        NavigationLink {
                            ProfileSettingsWidget()
                        } label: {
                            Image(systemName: "gearshape")
                        }
                    }
                }
        }
    }

    // MARK: - Internal

    @MainActor var profileContainer: some View {
        let container: ProfileWidget = parra.parraInternal
            .containerRenderer.renderContainer(
                params: .init(
                    api: parra.parraInternal.api
                ),
                config: config
            )

        return container
    }

    // MARK: - Private

    @Environment(\.parra) private var parra

    private let config: ProfileWidgetConfig
}

#Preview {
    ParraViewPreview { _ in
        ParraDefaultProfileView()
    }
}
