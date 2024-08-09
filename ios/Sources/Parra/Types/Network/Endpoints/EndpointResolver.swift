//
//  EndpointResolver.swift
//  Parra
//
//  Created by Mick MacCallum on 6/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

enum EndpointResolver {
    // MARK: - Internal

    static func resolve(
        endpoint: IssuerEndpoint,
        using appState: ParraAppState
    ) throws -> URL {
        guard let appInfo = appState.appInfo else {
            throw ParraError.message("App info is missing resolving endpoint")
        }

        return try resolve(
            endpoint: endpoint,
            tenant: appInfo.tenant
        )
    }

    static func resolve(
        endpoint: IssuerEndpoint,
        tenant: ParraTenantAppInfoStub
    ) throws -> URL {
        let path = path(for: endpoint)

        guard let issuerUrl = URL(string: "https://\(tenant.issuer)") else {
            throw ParraError.message(
                "Issuer host name could not be converted to URL."
            )
        }

        return issuerUrl.appending(
            path: path
        )
    }

    static func resolve(
        endpoint: ApiEndpoint,
        using appState: ParraAppState
    ) throws -> URL {
        let path = path(
            for: endpoint,
            using: appState
        )

        return ParraInternal.Constants.parraApiRoot
            .appendingPathComponent(path)
    }

    // MARK: - Private

    private static func path(
        for issuerEndpoint: IssuerEndpoint
    ) -> String {
        switch issuerEndpoint {
        case .postCreateUser:
            return "auth/signup"
        case .postAuthChallenges:
            return "auth/challenges"
        case .postPasswordless:
            return "auth/challenges/passwordless"
        case .postWebAuthnRegisterChallenge:
            return "auth/webauthn/register/challenge"
        case .postWebAuthnAuthenticateChallenge:
            return "auth/webauthn/authenticate/challenge"
        case .postWebAuthnRegister:
            return "auth/webauthn/register"
        case .postWebAuthnAuthenticate:
            return "auth/webauthn/authenticate"
        case .postAuthentication:
            return "auth/token"
        case .postPublicAuthentication:
            return "auth/issuers/public/token"
        case .postAnonymousAuthentication:
            return "auth/issuers/anonymous/token"
        case .postGuestAuthentication:
            return "auth/issuers/guest/token"
        case .postForgotPassword:
            return "auth/password/reset/challenge"
        case .postResetPassword:
            return "auth/password/reset"
        }
    }

    private static func path(
        for apiEndpoint: ApiEndpoint,
        using appState: ParraAppState
    ) -> String {
        let tenantId = appState.tenantId
        let applicationId = appState.applicationId

        switch apiEndpoint {
        case .postLogin:
            return "tenants/\(tenantId)/auth/login"
        case .postLogout:
            return "tenants/\(tenantId)/auth/logout"
        // Feedback
        case .getCards:
            return "cards"
        case .postBulkAnswerQuestions:
            return "bulk/questions/answer"
        // Feedback Forms
        case .getFeedbackForm(let formId):
            return "feedback/forms/\(formId)"
        case .postSubmitFeedbackForm(let formId):
            return "feedback/forms/\(formId)/submit"
        // Sessions
        case .postBulkSubmitSessions:
            return "tenants/\(tenantId)/sessions"
        // Push
        case .postPushTokens:
            return "tenants/\(tenantId)/push-tokens"
        // Roadmap
        case .getRoadmap:
            return "tenants/\(tenantId)/applications/\(applicationId)/roadmap"
        case .getPaginateTickets:
            return "tenants/\(tenantId)/applications/\(applicationId)/tickets"
        case .postVoteForTicket(let ticketId):
            return "tenants/\(tenantId)/tickets/\(ticketId)/vote"
        case .deleteVoteForTicket(let ticketId):
            return "tenants/\(tenantId)/tickets/\(ticketId)/vote"
        // Releases
        case .getRelease(let releaseId):
            return "tenants/\(tenantId)/applications/\(applicationId)/releases/\(releaseId)"
        case .getPaginateReleases:
            return "tenants/\(tenantId)/applications/\(applicationId)/releases"
        case .getAppInfo:
            return "tenants/\(tenantId)/applications/\(applicationId)/app-info"
        // Users
        case .getUserInfo:
            return "tenants/\(tenantId)/auth/user-info"
        case .updateUserInfo(let userId):
            return "tenants/\(tenantId)/users/\(userId)"
        case .postUpdateAvatar:
            return "tenants/\(tenantId)/users/avatar"
        case .deleteAvatar(let userId):
            return "tenants/\(tenantId)/users/\(userId)/avatar"
        case .deleteUser(let userId):
            return "tenants/\(tenantId)/users/\(userId)"
        }
    }
}
