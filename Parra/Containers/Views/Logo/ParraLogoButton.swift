//
//  ParraLogoButton.swift
//  Parra
//
//  Created by Mick MacCallum on 1/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ParraLogoButton: View {
    @Environment(Parra.self) var parra

    var type: ParraLogoType

    var body: some View {
        Button {
            parra.logEvent(.tap(element: "powered-by-parra"))

            UIApplication.shared.open(Parra.Constants.parraWebRoot)
        } label: {
            ParraLogo(type: type)
        }
    }
}

#Preview {
    ParraViewPreview {
        ParraLogoButton(type: .poweredBy)
    }
}
