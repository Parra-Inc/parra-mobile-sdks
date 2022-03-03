//
//  ParraFeedback.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 11/22/21.
//

import Foundation
import UIKit

let kParraLogPrefix = "[PARRA FEEDBACK]"
let kParraApiUrl = URL(string: "https://api.parra.io/v1/")!

public typealias ParraFeedbackAuthenticationProvider = () async throws -> ParraFeedbackCredential

public class ParraFeedback {
    static let shared = ParraFeedback()
    private var isInitialized = false
    let dataManager = ParraFeedbackDataManager()
    var authenticationProvider: ParraFeedbackAuthenticationProvider?
    
    internal lazy var urlSession: URLSession = {
        return URLSession(configuration: .default)
    }()
    
    private init() {
        UIFont.registerFontsIfNeeded()
    }
    
    // TODO: Need to either await this in all public methods, or figure out a way to call this
    // TODO: on init, but still guarentee that it has happened before public methods can be called.
    func ensureInitialized() async {
        if isInitialized {
            return
        }
        
        do {
            try await dataManager.loadData()
            
            isInitialized = true
        } catch let error {
            let dataError = ParraFeedbackError.dataLoadingError(error)
            print("\(kParraLogPrefix) Error loading data: \(dataError)")
        }
    }
    
    // TODO: Do we really even need this???
    public class func logout() {
//        shared.dataManager.credentialStorage.updateCredential(credential: nil)
        // TODO: data manager clear all data.
    }
        
    public class func fetchFeedbackCards() async throws -> CardsResponse {        
        let url = kParraApiUrl.appendingPathComponent("cards")
        let credential = await shared.dataManager.getCurrentCredential()

        let cardsResponse: CardsResponse = try await shared.performAuthenticatedRequest(
            url: url,
            method: .get,
            credential: credential,
            authenticationProvider: shared.refreshAuthentication
        )
        
//        shared.dataManager.
//        cardsResponse.items
        return cardsResponse
    }
}
