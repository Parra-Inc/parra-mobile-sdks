//
//  PushSettingsPermissionHeader.swift
//  Parra
//
//  Created by Mick MacCallum on 12/5/24.
//

import SwiftUI

struct PushSettingsPermissionHeader: View {
    let config: ParraUserNotificationSettingsConfiguration

    @Environment(\.parra) private var parra
    @State var authorizationStatus: UNAuthorizationStatus = .notDetermined

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraAppInfo) private var appInfo
    @Environment(\.openURL) var openURL

    @ViewBuilder
    private func renderUnauthorized(
        with permissionInfo: ParraUserNotificationSettingsConfiguration.PermissionInfo
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            componentFactory.buildLabel(
                text: permissionInfo.title,
                localAttributes: .default(with: .title3)
            )

            componentFactory.buildLabel(
                text: permissionInfo.description
            )
            .padding(.bottom, 16)

            componentFactory.buildContainedButton(
                config: .init(
                    size: .medium,
                    isMaxWidth: true
                ),
                text: permissionInfo.actionTitle,
                localAttributes: .init(normal: .init(
                    padding: .zero
                ))
            ) {
                promptForPushPermission()
            }
        }
        .padding(.vertical, 10)
    }

    @ViewBuilder private var content: some View {
        switch authorizationStatus {
        case .notDetermined:
            renderUnauthorized(
                with: config.notDeterminedStatusInfo
            )
        case .denied:
            VStack(alignment: .leading, spacing: 4) {
                componentFactory.buildLabel(
                    text: config.deniedStatusInfo.title,
                    localAttributes: .default(with: .title3)
                )

                componentFactory.buildLabel(
                    text: config.deniedStatusInfo.description
                )
                .padding(.bottom, 16)

                componentFactory.buildContainedButton(
                    config: .init(
                        size: .medium,
                        isMaxWidth: true
                    ),
                    text: config.deniedStatusInfo.actionTitle,
                    localAttributes: .init(normal: .init(
                        padding: .zero
                    ))
                ) {
                    openSettings()
                }
            }
            .padding(.vertical, 10)
        case .authorized:
            EmptyView()
        case .provisional:
            renderUnauthorized(
                with: config.provisionalStatusInfo
            )
        case .ephemeral:
            // Only relevant to App Clips
            EmptyView()
        default:
            EmptyView()
        }
    }

    var body: some View {
        content.onAppear {
            if !UIDevice.isPreview {
                checkAuthorizationStatus()
            }
        }
    }

    private func promptForPushPermission() {
        Task { @MainActor in

            do {
                try await parra.push.requestPushPermission()

                checkAuthorizationStatus()
            } catch {}
        }
    }

    private func openSettings() {
        openURL.callAsFunction(
            URL(string: UIApplication.openNotificationSettingsURLString)!
        ) { accepted in
            if accepted {
                Task { @MainActor in
                    parra.logEvent(.action(source: "open_system_settings"))
                }
            }
        }
    }

    private func checkAuthorizationStatus() {
        Task { @MainActor in
            authorizationStatus = await parra.push.getCurrentAuthorizationStatus()
        }
    }
}

#Preview {
    ParraAppPreview {
        List {
            Section {
                PushSettingsPermissionHeader(
                    config: .default,
                    authorizationStatus: .notDetermined
                )
            }

            Section {
                PushSettingsPermissionHeader(
                    config: .default,
                    authorizationStatus: .denied
                )
            }

            Section {
                PushSettingsPermissionHeader(
                    config: .default,
                    authorizationStatus: .authorized
                )
            }

            Section {
                PushSettingsPermissionHeader(
                    config: .default,
                    authorizationStatus: .provisional
                )
            }
        }
    }
}
