//
//  AlertManager.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

class AlertManager: ObservableObject {
    @Published var currentLoadingIndicator: LoadingIndicator?
    @Published var currentToast: Toast?
}
