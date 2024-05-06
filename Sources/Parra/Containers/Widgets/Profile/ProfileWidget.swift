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
        componentFactory: ComponentFactory,
        contentObserver: ContentObserver
    ) {
        self.config = config
        self.style = style
        self.componentFactory = componentFactory
        self._contentObserver = StateObject(wrappedValue: contentObserver)
    }

    // MARK: - Internal

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
                PhotoWell(stub: user.userInfo?.avatar) { newAvatar in
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
    ParraContainerPreview<ProfileWidget> { parra, factory, config in
        ProfileWidget(
            config: .default,
            style: .default(with: .default),
            componentFactory: factory,
            contentObserver: .init(
                initialParams: .init(
                    api: parra.parraInternal.api
                )
            )
        )
    }
}
