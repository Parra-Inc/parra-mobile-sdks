//
//  ContentCard+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import SwiftUI

extension ParraContentCard: ParraFixture {
    static func validStates() -> [ParraContentCard] {
        return [
            ParraContentCard(
                id: .uuid,
                createdAt: .now.daysAgo(3),
                updatedAt: .now.daysAgo(3),
                deletedAt: nil,
                backgroundImage: ParraContentCardBackground(
                    image: ParraImageAssetStub(
                        id: .uuid,
                        size: ParraSize(
                            width: 5_616,
                            height: 3_744
                        ),
                        url: URL(
                            string: "https://image-asset-bucket-production.s3.amazonaws.com/tenants/4caab3fe-d0e7-4bc3-9d0a-4b36f32bd1b7/releases/8d548ef4-d652-473b-91b9-bcb4bb4d4202/header/42af8595-57d9-495a-ba4b-625dca5418e9.jpg"
                        )!
                    )
                ),
                title: "Big news!",
                description: "We're excited to announce that this year's Halloween merch is finally available! Get yours today!",
                action: ParraContentCardAction(
                    url: URL(string: "https://parra.io")!
                )
            )
        ]
    }

    static func invalidStates() -> [ParraContentCard] {
        return []
    }
}
