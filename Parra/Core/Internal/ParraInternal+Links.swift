//
//  ParraInternal+Links.swift
//  Parra
//
//  Created by Mick MacCallum on 3/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import UIKit

extension ParraInternal {
    func openTrackedSiteLink(
        medium: String
    ) {
        let app = UIApplication.shared

        logEvent(.tap(element: "powered-by-parra"), [
            "medium": medium
        ])

        let bundleId = configuration.appInfoOptions.bundleId

        guard var components = URLComponents(
            url: Parra.Constants.parraWebRoot,
            resolvingAgainstBaseURL: true
        ) else {
            Logger.warn("Failed to create url components to open site")

            return
        }

        components.queryItems = [
            URLQueryItem(
                name: "utm_medium",
                value: medium
            ),
            URLQueryItem(
                name: "utm_source",
                value: "parra_ios_\(bundleId)"
            )
        ]

        guard let url = components.url else {
            Logger.warn("Failed to create link to open site")

            return
        }

        guard app.canOpenURL(url) else {
            Logger.warn("Failed to open link to site", [
                "url": url.absoluteString
            ])

            return
        }

        app.open(url)
    }
}
