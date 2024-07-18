//
//  ProfileCell.swift
//  Sample
//
//  Created by Mick MacCallum on 7/17/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Parra
import SwiftUI

public struct ProfileCell: View {
    // MARK: - Public

    public var body: some View {
        switch parraAuthState.current {
        case .authenticated(let user):
            AuthenticatedProfileInfoView(user: user)
        case .unauthenticated(let error):
            UnauthenticatedProfileInfoView(error: error)
        case .undetermined:
            EmptyView()
        }
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
    @EnvironmentObject private var themeObserver: ParraThemeObserver
    @EnvironmentObject private var parraAuthState: ParraAuthState
}

struct IdentityLabels: View {
    let user: ParraUser

    var body: some View {
        let names = user.identityNames

        if names.isEmpty {
            Text("Unknown")
                .font(.headline)
        } else if names.count == 1 {
            Text(names[0])
                .font(.headline)
        } else {
            Text(names[0])
                .font(.headline)

            Text(names[1])
                .font(.subheadline)
                .foregroundStyle(.gray)
        }
    }
}

struct AuthenticatedProfileInfoView: View {
    // MARK: - Internal

    let user: ParraUser

    @ViewBuilder var labels: some View {
        VStack(alignment: .leading) {
            IdentityLabels(user: user)
        }
    }

    var body: some View {
        NavigationLink {
            AccountView()
        } label: {
            HStack(alignment: .center, spacing: 12) {
                ParraProfilePhotoWell()
                    .disabled(true)

                labels

                Spacer()
            }
            .padding(.vertical, 6)
        }
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
}

struct UnauthenticatedProfileInfoView: View {
    let error: Error?

    var body: some View {
        Button(action: {}, label: {
            Text("Sign in")
        })
    }
}

#Preview {
    VStack(spacing: 50) {
        ParraAppPreview(authState: .authenticatedPreview) {
            ProfileCell()
        }

        ParraAppPreview(authState: .unauthenticatedPreview) {
            ProfileCell()
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(UIColor.secondarySystemBackground))
}
