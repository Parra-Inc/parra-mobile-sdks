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
                    avatar: ParraImageAsset(
                        id: .uuid,
                        size: CGSize(width: 4_284, height: 4_284),
                        url: URL(
                            string: "https://parra-cdn.com/users/9a311ff4-6af9-445e-a3df-6900787e2198/avatar/807a9033-0d1b-41d8-9102-3dc47f0c3e32.jpg"
                        )!
                    ),
                    verified: true
                ),
                attachments: [
                    ParraCreatorUpdateAttachmentStub(
                        id: .uuid,
                        image: ParraImageAsset(
                            id: .uuid,
                            size: CGSize(width: 1_075, height: 2_048),
                            url: URL(
                                string: "https://parra-cdn.com/tenants/201cbcf0-b5d6-4079-9e4d-177ae04cc9f4/creator-updates/0815cbd2-8168-46f0-8881-fac8e7fd9661/attachments/e5296c9c-abaa-429f-af89-61b4cb02dd57.png"
                            )!
                        )
                    ),
                    ParraCreatorUpdateAttachmentStub(
                        id: .uuid,
                        image: ParraImageAsset(
                            id: .uuid,
                            size: CGSize(width: 1_075, height: 2_048),
                            url: URL(
                                string: "https://parra-cdn.com/tenants/201cbcf0-b5d6-4079-9e4d-177ae04cc9f4/creator-updates/0815cbd2-8168-46f0-8881-fac8e7fd9661/attachments/afe3eaf7-b7f5-48df-96d3-a1ea3471419a.png"
                            )!
                        )
                    ),
                    ParraCreatorUpdateAttachmentStub(
                        id: .uuid,
                        image: ParraImageAsset(
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
