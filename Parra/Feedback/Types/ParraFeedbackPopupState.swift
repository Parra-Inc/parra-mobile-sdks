//
//  ParraFeedbackPopupState.swift
//  Parra
//
//  Created by Mick MacCallum on 7/2/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal actor ParraFeedbackPopupState {
    static let shared = ParraFeedbackPopupState()

    var isPresented = false

    func present() async {
        isPresented = true
    }

    func dismiss() async {
        isPresented = false
    }
}
