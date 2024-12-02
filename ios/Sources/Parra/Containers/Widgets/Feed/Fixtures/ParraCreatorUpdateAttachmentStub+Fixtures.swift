//
//  ParraCreatorUpdateAttachmentStub+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 10/27/24.
//

import SwiftUI

extension ParraCreatorUpdateAttachmentStub: ParraFixture {
    public static func validStates() -> [ParraCreatorUpdateAttachmentStub] {
        return [
            ParraCreatorUpdateAttachmentStub(
                id: .uuid,
                image: ParraImageAsset(
                    id: .uuid,
                    size: CGSize(width: 4_284, height: 4_284),
                    url: URL(
                        string: "https://image-asset-bucket-production.s3.amazonaws.com/users/9a311ff4-6af9-445e-a3df-6900787e2198/avatar/075b05ea-999d-49b9-a48e-0e5bcc427e44.jpg"
                    )!
                )
            ),
            ParraCreatorUpdateAttachmentStub(
                id: .uuid,
                image: ParraImageAsset(
                    id: .uuid,
                    size: CGSize(width: 600, height: 300),
                    url: URL(
                        string: "https://image-asset-bucket-production.s3.amazonaws.com/tenants/0c6583c7-a1ed-4c8e-8373-d728986e6d53/creator-update-attachment/af444818-5f4b-4b14-94ff-14153a1daa55.png"
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
            ),
            ParraCreatorUpdateAttachmentStub(
                id: .uuid,
                image: ParraImageAsset(
                    id: .uuid,
                    size: CGSize(width: 2_940, height: 1_960),
                    url: URL(
                        string: "https://plus.unsplash.com/premium_photo-1695635984394-79e2f6e79f92?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
                    )!
                )
            ),
            ParraCreatorUpdateAttachmentStub(
                id: .uuid,
                image: ParraImageAsset(
                    id: .uuid,
                    size: CGSize(width: 2_864, height: 3_580),
                    url: URL(
                        string: "https://images.unsplash.com/photo-1728875650224-fd3f375f6546?q=80&w=2864&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
                    )!
                )
            )
        ]
    }

    public static func invalidStates() -> [ParraCreatorUpdateAttachmentStub] {
        return []
    }
}
