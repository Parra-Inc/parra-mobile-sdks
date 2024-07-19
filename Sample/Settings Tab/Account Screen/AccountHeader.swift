//
//  AccountHeader.swift
//  Sample
//
//  Created by Mick MacCallum on 7/19/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
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
