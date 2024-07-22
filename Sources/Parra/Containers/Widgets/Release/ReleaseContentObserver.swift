//
//  ReleaseContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 3/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

class ReleaseContentObserver: ContainerContentObserver {
    // MARK: - Lifecycle

    required init(initialParams: InitialParams) {
        self.initialParams = initialParams

        switch initialParams.contentType {
        case .newInstalledVersion(let newInstalledVersionInfo):
            self.content = AppReleaseContent(newInstalledVersionInfo)
        case .stub(let appReleaseStub):
            self.content = AppReleaseContent(appReleaseStub)
        }

        self.api = initialParams.api
    }

    // MARK: - Internal

    @Published private(set) var content: AppReleaseContent
    @Published private(set) var isLoading = false

    let api: API

    var releaseStub: AppReleaseStub? {
        switch initialParams.contentType {
        case .stub(let appReleaseStub):
            return appReleaseStub
        default:
            return nil
        }
    }

    @MainActor
    func loadSections() async {
        guard content.sections.isEmpty else {
            return
        }

        do {
            isLoading = true

            let response = try await api.getRelease(
                with: content.id
            )

            content = AppReleaseContent(response)
        } catch {
            Logger.error("Error loading sections for release", error, [
                "releaseId": content.id
            ])
        }

        isLoading = false
    }

    // MARK: - Private

    private let initialParams: InitialParams
}
