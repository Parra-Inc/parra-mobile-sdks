//
//  ProfileWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 4/30/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ProfileWidget: Container {
    // MARK: - Lifecycle

    init(
        config: ProfileWidgetConfig,
        style: ProfileWidgetStyle,
        localBuilderConfig: ProfileWidgetBuilderConfig,
        componentFactory: ComponentFactory,
        contentObserver: ContentObserver
    ) {
        self.config = config
        self.style = style
        self.localBuilderConfig = localBuilderConfig
        self.componentFactory = componentFactory
        self._contentObserver = StateObject(wrappedValue: contentObserver)
    }

    // MARK: - Internal

    let localBuilderConfig: ProfileWidgetBuilderConfig
    let componentFactory: ComponentFactory
    @StateObject var contentObserver: ContentObserver
    let config: ProfileWidgetConfig
    let style: ProfileWidgetStyle

    @EnvironmentObject var themeObserver: ParraThemeObserver

    var body: some View {
        VStack {
            Text("Profile")

            switch authState.current {
            case .authenticated(let user):
                PhotoWell(url: user.userInfo?.avatar?.url) { newAvatar in
                    await contentObserver.onAvatarSelectionChange(
                        image: newAvatar
                    )
                }

//                Text("User: \(user.userInfo)")
//                Text(user.userInfo?.name ?? "unknown")
//                Text(user.userInfo?.firstName ?? "unknown")
//                Text(user.userInfo?.lastName ?? "unknown")
                Text(user.userInfo?.email ?? "unknown")
            case .unauthenticated(let error):
                Text("Error: \(error)")
            }

            Button("Logout") {
                parra.logout()
            }
        }
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
    @Environment(\.parraAuthState) private var authState
}

#Preview {
    ParraContainerPreview<ProfileWidget> { parra, factory, config, builderConfig in
        ProfileWidget(
            config: .default,
            style: .default(with: .default),
            localBuilderConfig: builderConfig,
            componentFactory: factory,
            contentObserver: .init(
                initialParams: .init(
                    api: parra.parraInternal.api
                )
            )
        )
    }
}
