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

    // Feedback
    case getCards
    case getFeedbackForm(formId: String)
    case postSubmitFeedbackForm(formId: String)
    case postBulkAnswerQuestions

    // Sessions
    case postBulkSubmitSessions(tenantId: String)

    // Push
    case postPushTokens(tenantId: String)

    // Roadmap

    case getRoadmap(tenantId: String, applicationId: String)
    case getPaginateTickets(tenantId: String, applicationId: String)
    case postVoteForTicket(tenantId: String, ticketId: String)
    case deleteVoteForTicket(tenantId: String, ticketId: String)

    // MARK: - Internal

    // All endpoints should use kebab case!
    var route: String {
        switch self {
        case .getCards:
            return "cards"
        case .getFeedbackForm(let formId):
            return "feedback/forms/\(formId)"
        case .postSubmitFeedbackForm(let formId):
            return "feedback/forms/\(formId)/submit"
        case .postBulkAnswerQuestions:
            return "bulk/questions/answer"
        case .postBulkSubmitSessions(let tenantId):
            return "tenants/\(tenantId)/sessions"
        case .postPushTokens(let tenantId):
            return "tenants/\(tenantId)/push-tokens"
        case .postAuthentication(let tenantId):
            return "tenants/\(tenantId)/issuers/public/auth/token"
        case .getRoadmap(let tenantId, let applicationId):
            return "tenants/\(tenantId)/applications/\(applicationId)/roadmap"
        case .getPaginateTickets(let tenantId, let applicationId):
            return "tenants/\(tenantId)/applications/\(applicationId)/tickets"
        case .postVoteForTicket(let tenantId, let ticketId):
            return "tenants/\(tenantId)/tickets/\(ticketId)/vote"
        case .deleteVoteForTicket(let tenantId, let ticketId):
            return "tenants/\(tenantId)/tickets/\(ticketId)/vote"
        }
    }

    var method: HttpMethod {
        switch self {
        case .getCards, .getFeedbackForm, .getRoadmap, .getPaginateTickets:
            return .get
        case .postBulkAnswerQuestions, .postSubmitFeedbackForm,
             .postBulkSubmitSessions,
             .postPushTokens, .postAuthentication, .postVoteForTicket:
            return .post
        case .deleteVoteForTicket:
            return .delete
        }
    }

    /// Whether extra session tracking information should be attached to the
    /// request headers.
    var isTrackingEnabled: Bool {
        switch self {
        case .postAuthentication, .postBulkSubmitSessions, .postPushTokens:
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
        case .getRoadmap:
            return "tenants/:tenantId/applications/:applicationId/roadmap"
        case .getPaginateTickets:
            return "tenants/:tenantId/applications/:applicationId/tickets"
        case .postVoteForTicket, .deleteVoteForTicket:
            return "tenants/:tenantId/tickets/:ticketId/vote"
        }
    }
}
