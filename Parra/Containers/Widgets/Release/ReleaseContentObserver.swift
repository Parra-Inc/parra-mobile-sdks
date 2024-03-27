//
//  ReleaseContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 3/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ReleaseContentObserver {
    enum ReleaseContentType {
        case newInstalledVersion(NewInstalledVersionInfo)
        case stub(AppReleaseStub)
    }

    struct InitialParams {
        let contentType: ReleaseContentType
        let networkManager: ParraNetworkManager
    }
}

class ReleaseContentObserver: ContainerContentObserver {
    // MARK: - Lifecycle

    required init(initialParams: InitialParams) {
        switch initialParams.contentType {
        case .newInstalledVersion(let newInstalledVersionInfo):
            self.content = AppReleaseContent(newInstalledVersionInfo)
        case .stub(let appReleaseStub):
            self.content = AppReleaseContent(appReleaseStub)
        }

        self.networkManager = initialParams.networkManager
    }

    // MARK: - Internal

    @Published private(set) var content: AppReleaseContent
    @Published private(set) var isLoading = false

    let networkManager: ParraNetworkManager

    func loadSections() async {
        guard content.sections.isEmpty else {
            return
        }

        do {
            await MainActor.run {
                isLoading = true
            }

            let response = try await networkManager.getRelease(
                with: content.id
            )

            await MainActor.run {
                content = AppReleaseContent(response)
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
