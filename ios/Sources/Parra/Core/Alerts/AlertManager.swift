//
//  AlertManager.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

@MainActor
@Observable
class AlertManager {
    var currentLoadingIndicator: LoadingIndicator?
    var currentToast: Toast?
}
