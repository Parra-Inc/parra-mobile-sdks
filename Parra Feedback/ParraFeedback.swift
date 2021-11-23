//
//  ParraFeedback.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 11/22/21.
//

import Foundation

public enum ParraFeedbackError: Error {
    case missingAuthentication
    case authenticationFailed(Error)
}

public struct ParraFeedbackUserCredential {
    public let name: String
    public let token: String
    
    public init(name: String, token: String) {
        self.name = name
        self.token = token
    }
}

//{
//        "id": "1",
//      "type": "choice|text|rating",
//        "title": "",
//        "subtitle": "",
//      "data": {
//            "type": "radio|checkbox|drop_down",
//          "options": [
//                {
//                    "title": "",
//                    "value": "",
//                    "is_other": "true|false"
//                }
//            ],
//      }
//}

public struct ParraFeedbackChoiceOption {
    let id: String
    let title: String
    let value: String
}

public enum ParraFeedbackChoiceOptionType: String {
    case radio = "radio"
    case checkbox = "checkbox"
    case dropDown = "drop_down"
}

public struct ParraFeedbackQuestionTypeChoice {
    let optionType: ParraFeedbackChoiceOptionType
    let options: [ParraFeedbackChoiceOption]
}

public struct ParraFeedbackQuestionTypeForm {
    let multiLine: Bool
    let placeholderText: String?
}

public enum ParraFeedbackQuestionType {
    case choice(ParraFeedbackQuestionTypeChoice)
    case form(ParraFeedbackQuestionTypeForm)
}

// Questions have different options like choice for multiple choice or free response.
public struct ParraFeedbackQuestion {
    let id: String
    let type: ParraFeedbackQuestionType
    let title: String
    let subtitle: String?
}

public enum ParraFeedbackCardItem {
    case question(ParraFeedbackQuestion)
}

public struct ParraFeedbackCardsResponse {
    let version: String
    let cards: [ParraFeedbackCardItem]
}

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
