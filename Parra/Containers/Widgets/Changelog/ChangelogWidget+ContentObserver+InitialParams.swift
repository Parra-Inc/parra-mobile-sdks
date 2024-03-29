//
//  ChangelogWidget+ContentObserver+InitialParams.swift
//  Parra
//
//  Created by Mick MacCallum on 3/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension ChangelogWidget.ContentObserver {
    struct InitialParams {
        let appReleaseCollection: AppReleaseCollectionResponse?
        let networkManager: ParraNetworkManager
    }
}
