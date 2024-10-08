//
//  ApiEndpoint.swift
//  Parra
//
//  Created by Mick MacCallum on 6/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

enum ApiEndpoint: Endpoint {
    // Auth
    case postLogin
    case postLogout

    // Feedback
    case getCards
    case postBulkAnswerQuestions

    // Feedback Forms
    case getFeedbackForm(formId: String)
    case postSubmitFeedbackForm(formId: String)

    // Sessions
    case postBulkSubmitSessions

    // Push
    case postPushTokens

    // Roadmap

    case getRoadmap
    case getPaginateTickets
    case postVoteForTicket(ticketId: String)
    case deleteVoteForTicket(ticketId: String)

    // Releases

    case getRelease(releaseId: String)
    case getPaginateReleases
    case getAppInfo

    // Users
    case getUserInfo
    case updateUserInfo(userId: String)
    case postUpdateAvatar
    case deleteAvatar(userId: String)
    case deleteUser(userId: String)

    // User Properties
    case getUserProperties(userId: String)
    case putReplaceUserProperties(userId: String)
    case patchUpdateUserProperties(userId: String)
    case deleteAllUserProperties(userId: String)

    case putUpdateSingleUserProperty(userId: String, propertyKey: String)
    case deleteSingleUserProperty(userId: String, propertyKey: String)

    // Feeds

    case getPaginateFeed(feedId: String)

    // MARK: - Internal

    var method: HttpMethod {
        switch self {
        case .getCards, .getFeedbackForm, .getRoadmap, .getPaginateTickets,
             .getRelease, .getPaginateReleases, .getAppInfo, .getUserInfo,
             .getUserProperties, .getPaginateFeed:
            return .get
        case .postBulkAnswerQuestions, .postSubmitFeedbackForm,
             .postBulkSubmitSessions,
             .postPushTokens, .postVoteForTicket,
             .postLogin, .postLogout, .postUpdateAvatar:
            return .post
        case .updateUserInfo, .putReplaceUserProperties,
             .putUpdateSingleUserProperty:
            return .put
        case .deleteVoteForTicket, .deleteUser, .deleteAvatar,
             .deleteAllUserProperties, .deleteSingleUserProperty:
            return .delete
        case .patchUpdateUserProperties:
            return .patch
        }
    }

    var slugWithMethod: String {
        return "\(method.rawValue) \(slug)"
    }

    var slug: String {
        switch self {
        case .getAppInfo: // auth is optional for this one.
            return "tenants/:tenantId/applications/:applicationId/app-info"
        case .postLogin:
            return "tenants/:tenantId/auth/login"
        case .postLogout:
            return "tenants/:tenantId/auth/logout"
        case .getUserInfo:
            return "tenants/:tenantId/auth/user-info"
        case .updateUserInfo:
            return "tenants/:tenantId/users/:userId"
        case .getCards:
            return "cards"
        case .getFeedbackForm:
            return "feedback/forms/:formId"
        case .postSubmitFeedbackForm:
            return "feedback/forms/:formId/submit"
        case .postBulkAnswerQuestions:
            return "bulk/questions/answer"
        case .postBulkSubmitSessions:
            return "tenants/:tenantId/sessions"
        case .postPushTokens:
            return "tenants/:tenantId/push-tokens"
        case .postUpdateAvatar:
            return "tenants/:tenantId/users/avatar"
        case .deleteAvatar:
            return "tenants/:tenantId/users/:userId/avatar"
        case .getRoadmap:
            return "tenants/:tenantId/applications/:applicationId/roadmap"
        case .getPaginateTickets:
            return "tenants/:tenantId/applications/:applicationId/tickets"
        case .postVoteForTicket, .deleteVoteForTicket:
            return "tenants/:tenantId/tickets/:ticketId/vote"
        case .getRelease:
            return "tenants/:tenantId/applications/:applicationId/releases/:releaseId"
        case .getPaginateReleases:
            return "tenants/:tenantId/applications/:applicationId/releases"
        case .deleteUser:
            return "tenants/:tenantId/users/:userId"
        case .getUserProperties, .putReplaceUserProperties,
             .patchUpdateUserProperties, .deleteAllUserProperties:
            return "tenants/:tenantId/users/:userId/properties"
        case .putUpdateSingleUserProperty, .deleteSingleUserProperty:
            return "tenants/:tenantId/users/:userId/properties/:userPropertyKey"
        case .getPaginateFeed:
            return "tenants/:tenantId/applications/:applicationId/feeds/:feedId/items"
        }
    }

    var isTrackingEnabled: Bool {
        switch self {
        // MUST check backend before removing any from this list
        case .postBulkSubmitSessions, .postPushTokens,
             .postLogin, .postLogout, .getUserInfo:
            return true
        default:
            return false
        }
    }

    var allowsGuestAuth: Bool {
        // "scope": "guest parra:app:app_info.read parra:app:core:roadmap.read parra:app:core:tickets.read parra:app:core:releases.read parra:app:core:release.read parra:app:core:cards.read parra:app:core:feedback_form.read parra:app:core:feedback_form.submit"

        switch self {
        case .getAppInfo, .getRoadmap, .getPaginateTickets,
             .getPaginateReleases, .getRelease, .getCards, .getFeedbackForm,
             .postSubmitFeedbackForm, .postPushTokens:
            return true
        default:
            return false
        }
    }
}
