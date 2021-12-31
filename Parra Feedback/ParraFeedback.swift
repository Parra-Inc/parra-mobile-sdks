//
//  ParraFeedback.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 11/22/21.
//

import Foundation

public class ParraFeedback {
    private static let shared = ParraFeedback()
    private var cachedUserCredential: ParraFeedbackUserCredential?
    
    public class func setAuthenticationProvider(provider: @escaping () async throws -> ParraFeedbackUserCredential) {
        Task {
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
