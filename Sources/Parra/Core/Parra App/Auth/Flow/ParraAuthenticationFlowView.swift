//
//  ParraAuthenticationFlowView.swift
//  Parra
//
//  Created by Mick MacCallum on 5/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// TODO: Break up ParraDefaultAuthenticationFlowView and actually use flow config

public struct ParraAuthenticationFlowView: View {
    // MARK: - Lifecycle

    public init(flowConfig: ParraAuthenticationFlowConfig) {
        self.flowConfig = flowConfig
    }

    // MARK: - Public

    public var body: some View {
        ParraDefaultAuthenticationFlowView()
    }

    // MARK: - Private

    private let flowConfig: ParraAuthenticationFlowConfig
}
