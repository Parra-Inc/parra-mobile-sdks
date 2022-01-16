//
//  ParraFeedback+Types.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 11/28/21.
//

import Foundation
import UIKit

public enum ParraFeedbackError: Error {
    case missingAuthentication
    case authenticationFailed(Error)
    case dataLoadingError(Error)
}

public struct ParraFeedbackUserCredential: Equatable {
    public let token: String
    public let name: String?

    public init(token: String, name: String? = nil) {
        self.token = token
        self.name = name
    }
    
    public static let defaultCredential = ParraFeedbackUserCredential(
        token: UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
    )
}
