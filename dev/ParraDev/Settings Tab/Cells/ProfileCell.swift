//
//  ProfileCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 08/01/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI
import UIKit

public struct ProfileCell: View {
    @EnvironmentObject private var parraAuthState: ParraAuthState

    public var body: some View {
        switch parraAuthState.current {
        case .authenticated, .anonymous:
            AuthenticatedProfileInfoView()
        case .error, .guest:
            UnauthenticatedProfileInfoView()
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
    @State private var isSigningIn = false

    var body: some View {
        Button(action: {
            isSigningIn = true
        }, label: {
            Text("Sign in")
        })
        .presentParraSignInView(isPresented: $isSigningIn)
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
