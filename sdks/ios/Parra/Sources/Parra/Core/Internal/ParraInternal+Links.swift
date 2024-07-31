//
//  ParraInternal+Links.swift
//  Parra
//
//  Created by Mick MacCallum on 3/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import UIKit

extension ParraInternal {
    func openLink(
        url: URL
    ) {
        let app = UIApplication.shared

        guard app.canOpenURL(url) else {
            Logger.warn("Failed to open link to site", [
                "url": url.absoluteString
            ])

            return
        }

        app.open(url)
    }

    func openTrackedSiteLink(
        medium: String
    ) {
        let bundleId = configuration.appInfoOptions.bundleId

        let params: [String: String] = [
            "utm_medium": medium,
            "utm_source": "parra_ios_\(bundleId)",
            "tenant_id": appState.tenantId,
            "application_id": appState.applicationId
        ]

        logEvent(.tap(element: "powered-by-parra"), params)

        guard var components = URLComponents(
            url: Parra.Constants.parraWebRoot,
            resolvingAgainstBaseURL: true
        ) else {
            Logger.warn("Failed to create url components to open site")

            return
        }

        components.queryItems = params.asCorrectlyEscapedQueryItems

        guard let url = components.url else {
            Logger.warn("Failed to create link to open site")

            return
        }

        openLink(url: url)
    }
}
