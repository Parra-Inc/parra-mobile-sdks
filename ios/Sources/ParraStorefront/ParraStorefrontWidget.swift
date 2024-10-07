//
//  ParraStorefrontWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 10/6/24.
//

import Parra
import SwiftUI

public struct ParraStorefrontWidget: View {
    // MARK: - Lifecycle

    public init() {}

    // MARK: - Public

    public var body: some View {
        Text("Hello, World!")
        Text(parraAuthState.user?.info.displayName ?? "idk")
    }

    // MARK: - Internal

    @Environment(\.parra) var parra
    @Environment(\.parraAuthState) var parraAuthState
}
