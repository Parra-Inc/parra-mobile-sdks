//
//  ProfileCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 08/01/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

public struct ProfileCell: View {
    // MARK: - Public

    public var body: some View {
        switch parraAuthState.current {
        case .authenticated, .anonymous, .guest:
            AuthenticatedProfileInfoView()
        case let .error(error):
            UnauthenticatedProfileInfoView(error: error)
        case .undetermined:
            EmptyView()
        }
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
    @EnvironmentObject private var themeManager: ParraThemeManager
    @EnvironmentObject private var parraAuthState: ParraAuthState
}

struct IdentityLabels: View {
    // MARK: - Internal

    var body: some View {
        labels
            .onReceive(parra.user.$current) { user in
                identityNames = user?.info.identityNames ?? []
            }
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
    @State private var identityNames: [String] = []

    @ViewBuilder private var labels: some View {
        if identityNames.isEmpty {
            Text(parra.user.current?.info.displayName ?? "Anonymous")
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
