//
//  ParraLogoButton.swift
//  Parra
//
//  Created by Mick MacCallum on 1/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct PoweredByParraButton: View {
    // MARK: - Lifecycle

    public init() {}

    // MARK: - Public

    public var body: some View {
        ParraLogoButton(type: .poweredBy)
    }
}

struct ParraLogoButton: View {
    @Environment(\.parra) var parra

    var type: ParraLogoType

    var body: some View {
        Button {
            parra.parraInternal.openTrackedSiteLink(
                medium: type.utmMedium
            )
        } label: {
            ParraLogo(type: type)
        }
    }
}

#Preview {
    ParraViewPreview { _ in
        ParraLogoButton(type: .poweredBy)
    }
}
