//
//  ProfileWidget+ContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 5/1/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// MARK: - ProfileWidget.ContentObserver

extension ProfileWidget {
    class ContentObserver: ContainerContentObserver {
        // MARK: - Lifecycle

        required init(initialParams: InitialParams) {
            self.content = Content()
        }

        // MARK: - Internal

        var content: Content
    }
}

// MARK: - ProfileWidget.ContentObserver.Content

extension ProfileWidget.ContentObserver {
    struct Content: ContainerContent {}
}

// MARK: - ProfileWidget.ContentObserver.InitialParams

extension ProfileWidget.ContentObserver {
    struct InitialParams {}
}
