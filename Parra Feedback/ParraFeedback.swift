//
//  ParraFeedback.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 11/22/21.
//

import Foundation
import UIKit

let kParraLogPrefix = "[PARRA FEEDBACK]"

public class ParraFeedback {
    private static let shared = ParraFeedback()
    private let dataManager = ParraFeedbackDataManager()
    private var cachedUserCredential: ParraFeedbackUserCredential?
    
    private init() {}
    
    public class func initialize(authenticationProvider provider: @escaping () async throws -> ParraFeedbackUserCredential) {
        UIFont.registerFontsIfNeeded()

        Task {
            do {
                try await shared.dataManager.loadData()
            } catch let error {
                let dataError = ParraFeedbackError.dataLoadingError(error)
                print("\(kParraLogPrefix) Error loading data: \(dataError)")
            }
            
            do {
                setUserCredential(try await provider())
            } catch let error {
                let authError = ParraFeedbackError.authenticationFailed(error)
                print("[PARRA FEEDBACK] Error authenticating user: \(authError)")
                setUserCredential(nil)
            }
        }
    }
    
    public class func logout() {
        setUserCredential(nil)
    }
    
    public class func fetchFeedbackCards() async throws -> CardsResponse {
        guard checkAuthenticationProvider() else {
            throw ParraFeedbackError.missingAuthentication
        }
        
        return CardsResponse(
            items: [
                CardItem(
                    type: .question,
                    version: "1",
                    data: .question(
                        Question(
                            id: "1",
                            createdAt: "",
                            updatedAt: "",
                            deletedAt: nil,
                            tenantId: "1",
                            title: "What do you want us to build next?",
                            subtitle: "Your feedback matters to us.",
                            type: .choice,
                            kind: .radio,
                            data: .choiceQuestionBody(ChoiceQuestionBody(options: [
                                ChoiceQuestionOption(
                                    title: "App Update Checker",
                                    value: "",
                                    isOther: nil,
                                    id: "opt1"
                                ),
                                ChoiceQuestionOption(
                                    title: "Analytics",
                                    value: "",
                                    isOther: nil,
                                    id: "opt2"
                                ),
                                ChoiceQuestionOption(
                                    title: "Auth Services",
                                    value: "",
                                    isOther: nil,
                                    id: "opt3"
                                )
                            ])),
                            active: true,
                            expiresAt: nil,
                            answerQuota: nil,
                            answer: nil
                        )
                    )
                ),
                CardItem(
                    type: .question,
                    version: "1",
                    data: .question(
                        Question(
                            id: "2",
                            createdAt: "",
                            updatedAt: "",
                            deletedAt: nil,
                            tenantId: "4",
                            title: "Which features of this app do you use every day?",
                            subtitle: "If none are applicable, that's okay!",
                            type: .choice,
                            kind: .checkbox,
                            data: .choiceQuestionBody(ChoiceQuestionBody(options: [
                                ChoiceQuestionOption(
                                    title: "Login screen",
                                    value: "",
                                    isOther: nil,
                                    id: "opt1"
                                ),
                                ChoiceQuestionOption(
                                    title: "Search function",
                                    value: "",
                                    isOther: nil,
                                    id: "opt2"
                                ),
                                ChoiceQuestionOption(
                                    title: "Browse screen",
                                    value: "",
                                    isOther: nil,
                                    id: "opt3"
                                )
                            ])),
                            active: true,
                            expiresAt: nil,
                            answerQuota: nil,
                            answer: nil
                        )
                    )
                )
            ]
        )
    }
    
    private class func checkAuthenticationProvider() -> Bool {
        return ParraFeedback.shared.cachedUserCredential != nil
    }
    
    private class func setUserCredential(_ credential: ParraFeedbackUserCredential?) {
        ParraFeedback.shared.cachedUserCredential = credential
    }
}
