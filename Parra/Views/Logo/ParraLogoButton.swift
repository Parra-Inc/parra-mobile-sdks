//
//  ParraLogoButton.swift
//  Parra
//
//  Created by Mick MacCallum on 1/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ParraLogoButton: View {
    var type: ParraLogoType

    var body: some View {
        Button {
            // TODO: SwiftUI hook into shared instance

//            Parra.logEvent(.tap(element: "powered-by-parra"))

            UIApplication.shared.open(Parra.Constants.parraWebRoot)
        } label: {
            ParraLogo(type: type)
        }
    }
}

#Preview {
    ParraLogoButton(type: .poweredBy)
}
