//
//  AccountHeader.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 01/09/2025.
//  Copyright © 2025 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

struct AccountHeader: View {
    var body: some View {
        VStack {
            ParraProfilePhotoWell(
                size: CGSize(width: 100, height: 100)
            )
            .padding(.bottom, 6)

            IdentityLabels()
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}
