//
//  ChallengeVerificationView.swift
//  Parra
//
//  Created by Mick MacCallum on 5/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ChallengeVerificationView: View {
    // MARK: - Lifecycle

    init(
        passwordlessConfig: ParraAuthInfoPasswordlessConfig,
        disabled: Bool = false,
        autoSubmit: Bool = true,
        onUpdate: @escaping (
            _: String, _: ParraAuthenticationMethod.PasswordlessType
        ) -> Void,
        onSubmit: @escaping (
            _: String, _: ParraAuthenticationMethod.PasswordlessType
        ) -> Void
    ) {
        self.passwordlessConfig = passwordlessConfig
        self.disabled = disabled
        self.autoSubmit = autoSubmit
        self.onUpdate = onUpdate
        self.onSubmit = onSubmit
    }

    // MARK: - Internal

    let passwordlessConfig: ParraAuthInfoPasswordlessConfig

    let disabled: Bool
    let autoSubmit: Bool

    let onUpdate: (
        _ challenge: String,
        _ type: ParraAuthenticationMethod.PasswordlessType
    ) -> Void

    let onSubmit: (
        _ code: String,
        _ type: ParraAuthenticationMethod.PasswordlessType
    ) -> Void

    @ViewBuilder var body: some View {
        if let sms = passwordlessConfig.sms {
            CodeEntryView(
                length: sms.otpLength,
                disabled: disabled,
                autoSubmit: autoSubmit
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
            passwordlessConfig: ParraAuthInfoPasswordlessConfig(
                sms: AuthInfoPasswordlessSmsConfig(
                    otpLength: 6
                )
            )
        ) { _, _ in } onSubmit: { _, _ in }
    }
}
