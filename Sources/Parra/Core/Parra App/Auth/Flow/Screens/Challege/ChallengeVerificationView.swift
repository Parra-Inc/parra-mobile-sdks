//
//  ChallengeVerificationView.swift
//  Parra
//
//  Created by Mick MacCallum on 5/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ChallengeVerificationView: View {
    let passwordlessConfig: AuthInfoPasswordlessConfig

    let onUpdate: (
        _ challenge: String,
        _ type: AuthenticationMethod.PasswordlessType
    ) -> Void

    let onSubmit: (
        _ code: String,
        _ type: AuthenticationMethod.PasswordlessType
    ) -> Void

    @ViewBuilder var body: some View {
        if let sms = passwordlessConfig.sms {
            CodeEntryView(
                length: sms.otpLength
            ) { code in
                onUpdate(code, .sms)
            } onComplete: { code in
                onSubmit(code, .sms)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        // TODO: else if let email = passwordlessConfig.email { ...
    }
}

#Preview {
    ParraViewPreview { _ in
        ChallengeVerificationView(
            passwordlessConfig: AuthInfoPasswordlessConfig(
                sms: AuthInfoPasswordlessSmsConfig(
                    otpLength: 6
                )
            )
        ) { _, _ in } onSubmit: { _, _ in }
    }
}
