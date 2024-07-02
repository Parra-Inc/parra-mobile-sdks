//
//  ProfileWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 4/30/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger()

struct ProfileWidget: Container {
    // MARK: - Lifecycle

    init(
        config: ProfileWidgetConfig,
        componentFactory: ComponentFactory,
        contentObserver: ContentObserver
    ) {
        self.config = config
        self.componentFactory = componentFactory
        self._contentObserver = StateObject(wrappedValue: contentObserver)
    }

    // MARK: - Internal

    let componentFactory: ComponentFactory
    @StateObject var contentObserver: ContentObserver
    let config: ProfileWidgetConfig

    @EnvironmentObject var themeObserver: ParraThemeObserver
    @EnvironmentObject var parraAuthState: ParraAuthState

    var body: some View {
        VStack(spacing: 16) {
            Text("Profile")

            switch parraAuthState.current {
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
                Text("Error: \(String(describing: error))")
            case .undetermined:
                Text("Unknown")
            }

            Button("Logout") {
                parra.auth.logout()
            }

            Button("Add Passkey") {
                Task {
                    do {
                        try await parra.parraInternal.authService
                            .linkPasskeyToAccount()
                    } catch {
                        logger
                            .error(
                                "Failed to link passkey to account: \(error)"
                            )
                    }
                }
            }
        }
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
}

#Preview {
    ParraContainerPreview<ProfileWidget> { parra, factory, config in
        ProfileWidget(
            config: .default,
            componentFactory: factory,
            contentObserver: .init(
                initialParams: .init(
                    api: parra.parraInternal.api
                )
            )
        )
    }
}
