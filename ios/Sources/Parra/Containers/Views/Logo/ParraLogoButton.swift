//
//  ParraLogoButton.swift
//  Parra
//
//  Created by Mick MacCallum on 1/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ParraLogoButton: View {
    @Environment(\.parra) private var parra
    @EnvironmentObject private var appInfo: ParraAppInfo

    var type: ParraLogoType

    var body: some View {
        if !appInfo.tenant.hideBranding {
            Button {
                parra.parraInternal.openTrackedSiteLink(
                    medium: type.utmMedium
                )
            } label: {
                ParraLogo(type: type)
            }
        }
    }
}

#Preview {
    ParraViewPreview { _ in
        ParraLogoButton(type: .poweredBy)
    }
}
