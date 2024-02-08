//
//  Container+Env.swift
//  Parra
//
//  Created by Mick MacCallum on 1/30/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension Container {
    func withEnvironmentObjects(
        _ content: () -> some View
    ) -> some View {
        return content()
            .environmentObject(contentObserver)
            .environmentObject(themeObserver)
    }
}
