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
            ]
        )
        
//        return ParraFeedbackCardsResponse(
//            version: "1",
//            cards: [
//                .question(
//                    ParraFeedbackQuestion(
//                        id: "q1",
//                        type: .choice(
//                            ParraFeedbackQuestionTypeChoice(
//                                optionType: .radio,
//                                options: [
//                                    .init(id: "opt1", title: "App Update Checker", value: ""),
//                                    .init(id: "opt1", title: "Analytics", value: ""),
//                                    .init(id: "opt2", title: "Auth Services", value: "")
//                                ]
//                            )
//                        ),
//                        title: "What do you want us to build next?",
//                        subtitle: "Your feedback matters to us."
//                    )
//                )
//            ]
//        )
    }
    
    private class func checkAuthenticationProvider() -> Bool {
        return ParraFeedback.shared.cachedUserCredential != nil
    }
    
    private class func setUserCredential(_ credential: ParraFeedbackUserCredential?) {
        ParraFeedback.shared.cachedUserCredential = credential
    }
}
