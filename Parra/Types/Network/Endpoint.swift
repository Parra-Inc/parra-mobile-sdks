//
//  Endpoint.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal enum ParraEndpoint: Hashable {
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
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(method)
        hasher.combine(route)
    }

    var method: HttpMethod {
        switch self {
        case .getCards, .getFeedbackForm:
            return .get
        case .postBulkAnswerQuestions, .postSubmitFeedbackForm, .postBulkSubmitSessions,
                .postPushTokens, .postAuthentication:
            return .post
        }
    }

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
        }
    }
}
