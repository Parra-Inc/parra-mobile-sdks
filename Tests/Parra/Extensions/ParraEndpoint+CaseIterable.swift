//
//  ParraEndpoint+CaseIterable.swift
//  Tests
//
//  Created by Mick MacCallum on 7/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
@testable import Parra

extension ParraEndpoint: CaseIterable {
    public static var allCases: [ParraEndpoint] = {
        let testCases: [ParraEndpoint] = [
            .getUserInfo(tenantId: ""),
            .getCards,
            .getFeedbackForm(formId: ""),
            .getRoadmap(tenantId: "", applicationId: ""),
            .getPaginateTickets(tenantId: "", applicationId: ""),
            .postAuthentication(tenantId: ""),
            .postAuthentication(tenantId: ""),
            .postPasswordless(tenantId: ""),
            .postCreateUser(tenantId: ""),
            .postLogin(tenantId: ""),
            .postLogout(tenantId: ""),
            .postWebAuthnRegisterChallenge(tenantId: ""),
            .postWebAuthnAuthenticateChallenge(tenantId: ""),
            .postBulkAnswerQuestions,
            .postBulkSubmitSessions(tenantId: ""),
            .postPushTokens(tenantId: ""),
            .postSubmitFeedbackForm(formId: ""),
            .postVoteForTicket(tenantId: "", ticketId: ""),
            .deleteVoteForTicket(tenantId: "", ticketId: ""),
            .getRelease(releaseId: "", tenantId: "", applicationId: ""),
            .getPaginateReleases(tenantId: "", applicationId: ""),
            .getAppInfo(tenantId: "", applicationId: "")
        ]

        // We can't automatically synthesize CaseIterable conformance, due to
        // this enum's cases having associated values, so we're providing the
        // list manually. We hard code the list then iterate through it to
        // ensure compiler errors here if new cases are added. Performance
        // doesn't matter since this only runs once, and only when
        // running tests.

        var finalCases = [ParraEndpoint]()
        for testCase in testCases {
            switch testCase {
            case .postAuthentication, .getUserInfo, .getCards, .getFeedbackForm,
                 .postSubmitFeedbackForm, .postBulkAnswerQuestions,
                 .postBulkSubmitSessions, .postPushTokens,
                 .getRoadmap, .getPaginateTickets, .postVoteForTicket,
                 .deleteVoteForTicket, .getRelease, .getPaginateReleases,
                 .getAppInfo, .postCreateUser, .postLogin, .postLogout,
                 .postUpdateAvatar, .postAuthChallenges, .postPasswordless,
                 .postWebAuthnRegisterChallenge,
                 .postWebAuthnAuthenticateChallenge:
                finalCases.append(testCase)
            }
        }

        return finalCases
    }()
}
