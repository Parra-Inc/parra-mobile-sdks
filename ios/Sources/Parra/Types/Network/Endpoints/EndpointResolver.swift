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
        tenant: ParraTenantAppInfoStub
    ) throws -> URL {
        let path = path(
            for: endpoint
        )

        guard let issuerUrl = URL(string: "https://\(tenant.issuer)") else {
            throw ParraError.message(
                "Issuer host name could not be converted to URL resolving endpoint: \(endpoint.displayName)"
            )
        }

        return issuerUrl.appending(
            path: path
        )
    }

    static func resolve(
        endpoint: ApiEndpoint,
        using appState: ParraAppState,
        dataManager: DataManager
    ) async throws -> URL {
        let path = try await path(
            for: endpoint,
            using: appState,
            dataManager: dataManager
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
        using appState: ParraAppState,
        dataManager: DataManager
    ) async throws -> String {
        let tenantId = appState.tenantId
        let applicationId = appState.applicationId

        switch apiEndpoint {
        // Assets
        case .postCreateAsset:
            return "tenants/\(tenantId)/assets/images"
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
        case .updateUserInfo:
            let userId = try await getUserId(
                for: apiEndpoint,
                from: dataManager
            )

            return "tenants/\(tenantId)/users/\(userId)"
        case .postUpdateAvatar:
            return "tenants/\(tenantId)/users/avatar"
        case .deleteAvatar:
            let userId = try await getUserId(
                for: apiEndpoint,
                from: dataManager
            )

            return "tenants/\(tenantId)/users/\(userId)/avatar"
        case .deleteUser:
            let userId = try await getUserId(
                for: apiEndpoint,
                from: dataManager
            )

            return "tenants/\(tenantId)/users/\(userId)"
        // User Properties
        case .getUserProperties, .putReplaceUserProperties,
             .patchUpdateUserProperties, .deleteAllUserProperties:
            let userId = try await getUserId(
                for: apiEndpoint,
                from: dataManager
            )

            return "tenants/\(tenantId)/users/\(userId)/properties"
        case .putUpdateSingleUserProperty(let propertyKey),
             .deleteSingleUserProperty(let propertyKey):
            let userId = try await getUserId(
                for: apiEndpoint,
                from: dataManager
            )

            return "tenants/\(tenantId)/users/\(userId)/properties/\(propertyKey)"
        // Feeds
        case .getPaginateFeed(let feedId):
            return "tenants/\(tenantId)/applications/\(applicationId)/feeds/\(feedId)/items"
        case .getFeedItem(let feedItemId):
            return "tenants/\(tenantId)/feed/items/\(feedItemId)"
        // Feed Admin
        case .getListCreatorUpdateTemplates:
            return "tenants/\(tenantId)/creator/updates/templates"
        case .postCreateCreatorUpdate:
            return "tenants/\(tenantId)/creator/updates"
        case .putUpdateCreatorUpdate(let creatorUpdateId):
            return "tenants/\(tenantId)/creator/updates/\(creatorUpdateId)"
        case .postSendCreatorUpdate(let creatorUpdateId):
            return "tenants/\(tenantId)/creator/updates/\(creatorUpdateId)/send"
        case .postCreateCreatorUpdateAttachment(let creatorUpdateId):
            return "tenants/\(tenantId)/creator/updates/\(creatorUpdateId)/attachments"
        // User Settings
        case .getUserSettingsLayouts:
            let userId = try await getUserId(
                for: apiEndpoint,
                from: dataManager
            )

            return "tenants/\(tenantId)/users/\(userId)/settings/views"
        case .getUserSettingsLayout(let layoutId):
            let userId = try await getUserId(
                for: apiEndpoint,
                from: dataManager
            )

            return "tenants/\(tenantId)/users/\(userId)/settings/views/\(layoutId)"
        case .putUpdateUserSetting(let settingsItemId):
            let userId = try await getUserId(
                for: apiEndpoint,
                from: dataManager
            )

            return "tenants/\(tenantId)/users/\(userId)/settings/items/\(settingsItemId)/value"
        case .getPaywall:
            return "tenants/\(tenantId)/applications/\(applicationId)/paywall"
        case .postPurchases:
            return "tenants/\(tenantId)/applications/\(applicationId)/purchases"
        case .getFaqs:
            return "tenants/\(tenantId)/applications/\(applicationId)/faqs"
        case .postFeedReaction(let feedItemId):
            return "tenants/\(tenantId)/feed/items/\(feedItemId)/reactions"
        case .deleteFeedReaction(let feedItemId, let reactionId):
            return "tenants/\(tenantId)/feed/items/\(feedItemId)/reactions/\(reactionId)"
        case .getPaginateComments(let feedItemId):
            return "tenants/\(tenantId)/feed/items/\(feedItemId)/comments"
        case .createFeedComment(let feedItemId):
            return "tenants/\(tenantId)/feed/items/\(feedItemId)/comments"
        case .updateComment(let commentId):
            return "tenants/\(tenantId)/comments/\(commentId)"
        case .deleteComment(let commentId):
            return "tenants/\(tenantId)/comments/\(commentId)"
        case .flagComment(let commentId):
            return "tenants/\(tenantId)/comments/\(commentId)/flag"
        case .postFeedCommentReaction(let commentId):
            return "tenants/\(tenantId)/comments/\(commentId)/reactions"
        case .deleteFeedCommentReaction(let commentId, let reactionId):
            return "tenants/\(tenantId)/comments/\(commentId)/reactions/\(reactionId)"
        // Chat
        case .postCreateChannel, .getListChatChannels:
            return "tenants/\(tenantId)/chat/channels"
        case .getChannel(let channelId):
            return "tenants/\(tenantId)/chat/channels/\(channelId)"
        case .getPaginateMessages(let channelId), .postSendMessage(let channelId):
            return "tenants/\(tenantId)/chat/channels/\(channelId)/messages"
        case .deleteMessage(let messageId):
            return "tenants/\(tenantId)/chat/messages/\(messageId)"
        case .postFlagMessage(let messageId):
            return "tenants/\(tenantId)/chat/messages/\(messageId)/flag"
        // Chat Admin
        case .postUnlockChannel(let channelId):
            return "tenants/\(tenantId)/chat/channels/\(channelId)/unlock"
        case .postLockChannel(let channelId):
            return "tenants/\(tenantId)/chat/channels/\(channelId)/lock"
        case .postLeaveChannel(let channelId):
            return "tenants/\(tenantId)/chat/channels/\(channelId)/leave"
        case .deleteArchiveChannel(let channelId):
            return "tenants/\(tenantId)/chat/channels/\(channelId)"
        // User Entitlements
        case .listUserEntitlements:
            let userId = try await getUserId(
                for: apiEndpoint,
                from: dataManager
            )

            return "tenants/\(tenantId)/users/\(userId)/entitlements"
        }
    }

    private static func getUserId(
        for endpoint: ApiEndpoint,
        from dataManager: DataManager
    ) async throws -> String {
        guard let userInfo = await dataManager.getCurrentUser()?.info else {
            throw ParraError.message(
                "Can not perform endpoint. Not logged in. Endpoint: \(endpoint.slugWithMethod)"
            )
        }

        return userInfo.id
    }
}
