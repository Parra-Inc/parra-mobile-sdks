//
//  ProfileCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 02/06/2025.
//  Copyright © 2025 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI
import UIKit

public struct ProfileCell: View {
    @Environment(\.parraAuthState) private var parraAuthState

    public var body: some View {
        switch parraAuthState {
        case .anonymous, .authenticated:
            AuthenticatedProfileInfoView()
        default:
            UnauthenticatedProfileInfoView()
        }
    }
}

struct IdentityLabels: View {
    @Environment(\.parraAuthState) private var parraAuthState

    var body: some View {
        let user = parraAuthState.user
        let identityNames = user?.info.identityNames ?? []

        if identityNames.isEmpty {
            Text(user?.info.displayName ?? "Anonymous")
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
        .presentParraSignInWidget(isPresented: $isSigningIn)
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
