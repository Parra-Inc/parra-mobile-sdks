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
        case .authenticated:
            AuthenticatedProfileInfoView()
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
    // MARK: - Internal

    var body: some View {
        Group {
            if identityNames.isEmpty {
                Text("Unknown")
                    .font(.headline)
            } else if identityNames.count == 1 {
                Text(identityNames[0])
                    .font(.headline)
            } else {
                Text(identityNames[0])
                    .font(.headline)

                Text(identityNames[1])
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
        }
        .onReceive(user.$current) { user in
            identityNames = user?.info.identityNames ?? []
        }
    }

    // MARK: - Private

    @Environment(\.parraUser) private var user
    @State private var identityNames: [String] = []
}

struct AuthenticatedProfileInfoView: View {
    // MARK: - Internal

    @ViewBuilder var labels: some View {
        VStack(alignment: .leading) {
            IdentityLabels()
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
