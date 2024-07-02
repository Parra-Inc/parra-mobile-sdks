//
//  AuthenticationFlowManagerDelegate.swift
//  Parra
//
//  Created by Mick MacCallum on 7/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

protocol AuthenticationFlowManagerDelegate {
    func presentModalLoadingIndicator(
        content: ParraLoadingIndicatorContent,
        with modalScreenManager: ModalScreenManager,
        completion: (() -> Void)?
    )

    func dismissModalLoadingIndicator(
        with modalScreenManager: ModalScreenManager,
        completion: (() -> Void)?
    )
}
