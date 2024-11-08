//
//  ParraAlertManager.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

@MainActor
@Observable
public final class ParraAlertManager {
    // MARK: - Lifecycle

    private init() {}

    // MARK: - Public

    public static let shared = ParraAlertManager()

    // MARK: - Internal

    var currentLoadingIndicator: LoadingIndicator?
    var currentToast: Toast?
}
