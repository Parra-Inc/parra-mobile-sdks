//
//  NavigationState.swift
//  Parra
//
//  Created by Mick MacCallum on 4/27/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

final class NavigationState: ObservableObject {
    @Published var navigationPath = NavigationPath()
}
