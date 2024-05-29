//
//  LegalInfo+ParraFixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 5/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension LegalInfo: ParraFixture {
    static func validStates() -> [LegalInfo] {
        return [
            LegalInfo(
                privacyPolicy: LegalDocument(
                    id: "710c75b9-3f52-4794-93c9-97a94f960683",
                    type: "privacy",
                    title: "Privacy Policy",
                    url: URL(string: "https://parra.io/privacy-policy")!
                ),
                termsOfService: LegalDocument(
                    id: "d62b4abf-d331-4a24-b21a-10f63cafbc8e",
                    type: "terms",
                    title: "Terms of Service",
                    url: URL(string: "https://parra.io/terms-of-service")!
                )
            )
        ]
    }

    static func invalidStates() -> [LegalInfo] {
        return []
    }
}
