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
    @Environment(\.parraAuthState) var authState

    var body: some View {
        VStack {
            Text("Profile")

            switch authState.current {
            case .authenticated(let user):
                Text("User: \(user)")
                Text(user.userInfo?.name ?? "unknown")
                Text(user.userInfo?.firstName ?? "unknown")
                Text(user.userInfo?.lastName ?? "unknown")
                Text(user.userInfo?.email ?? "unknown")
            case .unauthenticated(let error):
                Text("Error: \(error)")
            }

            Button("Logout") {
                parra.logout()
            }
        }
    }
}

#Preview {
    ProfileTab()
}
