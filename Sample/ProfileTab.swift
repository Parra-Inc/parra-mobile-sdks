//
//  ProfileTab.swift
//  Sample
//
//  Created by Mick MacCallum on 4/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Parra
import SwiftUI

struct ProfileTab: View {
    @Environment(\.parra) var parra

    var body: some View {
        VStack {
            Text("Profile")

            Button("Logout") {
                parra.logout()
            }
        }
    }
}

#Preview {
    ProfileTab()
}
