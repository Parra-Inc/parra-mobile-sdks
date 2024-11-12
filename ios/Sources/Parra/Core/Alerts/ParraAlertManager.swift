//
//  ParraAlertManager.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

@Observable
public final class ParraAlertManager {
    // MARK: - Lifecycle

    private init() {}

    // MARK: - Public

    public static let shared = ParraAlertManager()

    // MARK: - Internal

    @MainActor var currentLoadingIndicator: LoadingIndicator?

    @MainActor var currentToast: Toast?
}
