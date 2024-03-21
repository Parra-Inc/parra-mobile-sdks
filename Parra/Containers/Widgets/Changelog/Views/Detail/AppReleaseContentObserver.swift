//
//  AppReleaseContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 3/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

class AppReleaseContentObserver: ObservableObject {
    // MARK: - Lifecycle

    init(
        standalone: Bool,
        stub: AppReleaseStub,
        networkManager: ParraNetworkManager
    ) {
        self.standalone = standalone
        self.content = AppReleaseContent(stub, isStandalone: standalone)
        self.networkManager = networkManager
    }

    // MARK: - Internal

    /// Is being used on its own, aka the "What's New" view.
    let standalone: Bool

    @Published private(set) var content: AppReleaseContent
    @Published private(set) var isLoading = false

    let networkManager: ParraNetworkManager

    func loadSections() async {
        do {
            await MainActor.run {
                isLoading = true
            }

            let response = try await networkManager.getRelease(
                with: content.id
            )

            await MainActor.run {
                content = AppReleaseContent(response, isStandalone: standalone)
            }
        } catch {
            Logger.error("Error loading sections for release", error, [
                "releaseId": content.id
            ])
        }

        await MainActor.run {
            isLoading = false
        }
    }
}
