//
//  ParraCreatorUpdateAppStub+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 10/26/24.
//

import SwiftUI

extension ParraCreatorUpdateAppStub: ParraFixture {
    public static func validStates() -> [ParraCreatorUpdateAppStub] {
        return [
            ParraCreatorUpdateAppStub(
                id: .uuid,
                createdAt: .now,
                updatedAt: .now,
                deletedAt: nil,
                title: "Week 8 Picks",
                body: "I couldn't believe we landed so many great picks last week. This week is going to be wild.",
                sender: ParraCreatorUpdateSenderStub(
                    id: .uuid,
                    name: "Mick M.",
                    avatar: ParraImageAssetStub(
                        id: .uuid,
                        size: CGSize(width: 4_284, height: 4_284),
                        url: URL(
                            string: "https://image-asset-bucket-production.s3.amazonaws.com/users/9a311ff4-6af9-445e-a3df-6900787e2198/avatar/075b05ea-999d-49b9-a48e-0e5bcc427e44.jpg"
                        )!
                    ),
                    verified: true
                ),
                attachments: [
                    ParraCreatorUpdateAttachmentStub(
                        id: .uuid,
                        image: ParraImageAssetStub(
                            id: .uuid,
                            size: CGSize(width: 660, height: 300),
                            url: URL(
                                string: "https://image-asset-bucket-production.s3.amazonaws.com/tenants/0c6583c7-a1ed-4c8e-8373-d728986e6d53/creator-update-attachment/af444818-5f4b-4b14-94ff-14153a1daa55.png"
                            )!
                        )
                    ),
                    ParraCreatorUpdateAttachmentStub(
                        id: .uuid,
                        image: ParraImageAssetStub(
                            id: .uuid,
                            size: CGSize(width: 560, height: 560),
                            url: URL(
                                string: "https://image-asset-bucket-production.s3.amazonaws.com/tenants/0c6583c7-a1ed-4c8e-8373-d728986e6d53/creator-update-attachment/ddf7d09e-5e3c-452e-ab65-8504b68de604.jpg"
                            )!
                        )
                    ),
                    ParraCreatorUpdateAttachmentStub(
                        id: .uuid,
                        image: ParraImageAssetStub(
                            id: .uuid,
                            size: CGSize(width: 1_320, height: 420),
                            url: URL(
                                string: "https://image-asset-bucket-production.s3.amazonaws.com/tenants/0c6583c7-a1ed-4c8e-8373-d728986e6d53/creator-update-attachment/c7bab6d2-cb1d-46c7-9f5b-71753afa465a.png"
                            )!
                        )
                    )
                ],
                attachmentPaywall: ParraAppPaywallConfiguration(
                    entitlement: ParraEntitlement(
                        id: .uuid,
                        key: "something-important",
                        title: "Something important"
                    ),
                    context: "ctx"
                )
            )
        ]
    }

    public static func invalidStates() -> [ParraCreatorUpdateAppStub] {
        return []
    }
}
