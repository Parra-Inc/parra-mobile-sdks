//
//  ChangePasswordCell.swift
//  Sample
//
//  Created by Mick MacCallum on 7/16/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Parra
import SwiftUI

struct ChangePasswordCell: View {
    // MARK: - Internal

    var body: some View {
        Button(action: {
            parra.auth.deleteAccount()
        }) {
            Label(
                title: { Text("Change password") },
                icon: {
                    Image(systemName: "key.fill")
                }
            )
        }
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
}

#Preview {
    ParraAppPreview {
        ChangePasswordCell()
    }
}
