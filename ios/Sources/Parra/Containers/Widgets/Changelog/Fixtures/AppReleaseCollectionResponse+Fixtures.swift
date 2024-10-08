//
//  AppReleaseCollectionResponse+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 3/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension AppReleaseCollectionResponse: ParraFixture {
    public static func validStates() -> [AppReleaseCollectionResponse] {
        return [
            AppReleaseCollectionResponse(
                page: 1,
                pageCount: 3,
                pageSize: 4,
                totalCount: 10,
                data: AppReleaseStub.validStates()
            )
        ]
    }

    public static func invalidStates() -> [AppReleaseCollectionResponse] {
        return []
    }
}
