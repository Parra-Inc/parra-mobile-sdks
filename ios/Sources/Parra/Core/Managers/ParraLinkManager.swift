//
//  ParraLinkManager.swift
//  Parra
//
//  Created by Mick MacCallum on 10/30/24.
//

import SwiftUI

@MainActor
public class ParraLinkManager {
    // MARK: - Public

    public static let shared = ParraLinkManager()

    public func open(
        url: URL
    ) {
        guard let opener else {
            Logger.warn("Attempting to open URL without opener function set.", [
                "url": url.absoluteString
            ])

            return
        }

        opener(url)
    }

    // MARK: - Internal

    func registerUrlOpener(
        opener: @escaping (
            _ url: URL
        ) -> Void
    ) {
        self.opener = opener
    }

    // MARK: - Private

    private var opener: (
        (_ url: URL) -> Void
    )?
}
