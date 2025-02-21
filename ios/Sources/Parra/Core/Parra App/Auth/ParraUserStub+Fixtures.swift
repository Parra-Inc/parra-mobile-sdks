//
//  ParraUserStub+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 2/13/25.
//

import SwiftUI

extension ParraUserStub: ParraFixture {
    public static func validStates() -> [ParraUserStub] {
        return [
            ParraUserStub(
                id: .uuid,
                tenantId: .uuid,
                name: "John Appleseed",
                displayName: "User 123456",
                avatar: ParraImageAsset(
                    id: .uuid,
                    size: CGSize(width: 4_284, height: 4_284),
                    url: URL(
                        string: "https://parra-cdn.com/users/9a311ff4-6af9-445e-a3df-6900787e2198/avatar/807a9033-0d1b-41d8-9102-3dc47f0c3e32.jpg"
                    )!
                ),
                verified: nil,
                roles: []
            ),
            ParraUserStub(
                id: .uuid,
                tenantId: .uuid,
                name: "Steve Jobs",
                displayName: "Steve",
                avatar: ParraImageAsset(
                    id: .uuid,
                    size: CGSize(width: 4_284, height: 4_284),
                    url: URL(
                        string: "https://parra-cdn.com/users/9a311ff4-6af9-445e-a3df-6900787e2198/avatar/807a9033-0d1b-41d8-9102-3dc47f0c3e32.jpg"
                    )!
                ),
                verified: true,
                roles: [
                    ParraUserRoleStub(
                        id: .uuid,
                        name: "Admin",
                        key: "admin"
                    )
                ]
            )
        ]
    }
}
