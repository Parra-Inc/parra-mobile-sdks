//
//  ProfileCell.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import Parra
import SwiftUI

public struct ProfileCell: View {
    @EnvironmentObject private var parraAuthState: ParraAuthState

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
}

struct IdentityLabels: View {
    @Environment(\.parra) private var parra
    @State private var identityNames: [String] = []

    var body: some View {
        labels
            .onReceive(parra.user.$current) { user in
                identityNames = user?.info.identityNames ?? []
            }
    }

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
