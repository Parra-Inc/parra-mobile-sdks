//
//  Endpoint.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

enum ParraEndpoint {
    // Auth
    case postAuthentication(tenantId: String)
    case postCreateUser(tenantId: String)
    case postLogin(tenantId: String)
    case postLogout(tenantId: String)

    // Feedback
    case getCards
    case postBulkAnswerQuestions

    // Feedback Forms
    case getFeedbackForm(formId: String)
    case postSubmitFeedbackForm(formId: String)

    // Sessions
    case postBulkSubmitSessions(tenantId: String)

    // Push
    case postPushTokens(tenantId: String)

    // Roadmap

    case getRoadmap(tenantId: String, applicationId: String)
    case getPaginateTickets(tenantId: String, applicationId: String)
    case postVoteForTicket(tenantId: String, ticketId: String)
    case deleteVoteForTicket(tenantId: String, ticketId: String)

    // Releases

    case getRelease(releaseId: String, tenantId: String, applicationId: String)
    case getPaginateReleases(tenantId: String, applicationId: String)
    case getAppInfo(tenantId: String, applicationId: String)

    // Users
    case getUserInfo(tenantId: String)
    case postUpdateAvatar(tenantId: String)

    // MARK: - Internal

    enum EndpointType {
        case auth
    }

    var url: URL {
        switch self {
        case .postCreateUser(let tenantId):

            let baseHost = ParraInternal.Constants.parraApiHost
            let host = "tenant-\(tenantId).\(baseHost)"

            return URL(string: "https://\(host)/\(route)")!
        default:
            return ParraInternal.Constants.parraApiRoot
                .appendingPathComponent(route)
        }
    }

    var method: HttpMethod {
        switch self {
        case .getCards, .getFeedbackForm, .getRoadmap, .getPaginateTickets,
             .getRelease, .getPaginateReleases, .getAppInfo, .getUserInfo:
            return .get
        case .postBulkAnswerQuestions, .postSubmitFeedbackForm,
             .postBulkSubmitSessions, .postCreateUser,
             .postPushTokens, .postAuthentication, .postVoteForTicket,
             .postLogin, .postLogout, .postUpdateAvatar:
            return .post
        case .deleteVoteForTicket:
            return .delete
        }
    }

    /// Whether extra session tracking information should be attached to the
    /// request headers.
    var isTrackingEnabled: Bool {
        switch self {
        // MUST check backend before removing any from this list
        case .postAuthentication, .postBulkSubmitSessions, .postPushTokens,
             .postLogin, .postLogout, .getUserInfo:
            return true
        default:
            return false
        }
    }

    var displayName: String {
        return "\(method.rawValue.uppercased()) \(slug)"
    }

    var slug: String {
        switch self {
        case .getUserInfo:
            return "tenants/:tenantId/auth/user-info"
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
        case .postAuthentication:
            return "tenants/:tenantId/issuers/public/auth/token"
        case .postCreateUser:
            return "auth/signup"
        case .postLogin:
            return "tenants/:tenantId/auth/login"
        case .postLogout:
            return "tenants/:tenantId/auth/logout"
        case .postUpdateAvatar:
            return "tenants/:tenantId/users/avatar"
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
        case .getAppInfo:
            return "tenants/:tenantId/applications/:applicationId/app-info"
        }
    }

    // All endpoints should use kebab case!
    var route: String {
        switch self {
        // Auth
        case .postAuthentication(let tenantId):
            return "tenants/\(tenantId)/issuers/public/auth/token"
        case .postCreateUser:
            return "auth/signup"
        case .postLogin(let tenantId):
            return "tenants/\(tenantId)/auth/login"
        case .postLogout(let tenantId):
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
        case .postBulkSubmitSessions(let tenantId):
            return "tenants/\(tenantId)/sessions"

        // Push
        case .postPushTokens(let tenantId):
            return "tenants/\(tenantId)/push-tokens"

        // Roadmap
        case .getRoadmap(let tenantId, let applicationId):
            return "tenants/\(tenantId)/applications/\(applicationId)/roadmap"
        case .getPaginateTickets(let tenantId, let applicationId):
            return "tenants/\(tenantId)/applications/\(applicationId)/tickets"
        case .postVoteForTicket(let tenantId, let ticketId):
            return "tenants/\(tenantId)/tickets/\(ticketId)/vote"
        case .deleteVoteForTicket(let tenantId, let ticketId):
            return "tenants/\(tenantId)/tickets/\(ticketId)/vote"

        // Releases
        case .getRelease(let releaseId, let tenantId, let applicationId):
            return "tenants/\(tenantId)/applications/\(applicationId)/releases/\(releaseId)"
        case .getPaginateReleases(let tenantId, let applicationId):
            return "tenants/\(tenantId)/applications/\(applicationId)/releases"
        case .getAppInfo(let tenantId, let applicationId):
            return "tenants/\(tenantId)/applications/\(applicationId)/app-info"

        // Users
        case .getUserInfo(let tenantId):
            return "tenants/\(tenantId)/auth/user-info"
        case .postUpdateAvatar(let tenantId):
            return "tenants/\(tenantId)/users/avatar"
        }
    }
}
