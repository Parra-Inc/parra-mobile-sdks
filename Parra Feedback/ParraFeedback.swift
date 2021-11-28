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
    
    public class func fetchFeedbackCards() async throws -> ParraFeedbackCardsResponse {
        guard checkAuthenticationProvider() else {
            throw ParraFeedbackError.missingAuthentication
        }
        
        return ParraFeedbackCardsResponse(
            version: "1",
            cards: [
                .question(
                    ParraFeedbackQuestion(
                        id: "q1",
                        type: .choice(
                            ParraFeedbackQuestionTypeChoice(
                                optionType: .radio,
                                options: [
                                    .init(id: "opt1", title: "Option 1", value: ""),
                                    .init(id: "opt2", title: "Option 2", value: "")
                                ]
                            )
                        ),
                        title: "Title of question",
                        subtitle: "some subtitle"
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
