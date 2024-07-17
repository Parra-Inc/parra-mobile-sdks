//
//  UserProfileCell.swift
//  Sample
//
//  Created by Mick MacCallum on 7/17/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Parra
import SwiftUI

struct UserProfileCell: View {
    // MARK: - Internal

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ParraProfilePhotoWell()

            if let userInfo = parra.user?.userInfo {
                ProfileUserInfoView(userInfo: userInfo)
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
}

#Preview {
    ParraAppPreview {
        UserProfileCell()
    }
}
