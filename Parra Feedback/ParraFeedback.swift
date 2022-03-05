//
//  ParraFeedback.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 11/22/21.
//

import Foundation
import UIKit

public typealias ParraFeedbackAuthenticationProvider = () async throws -> ParraFeedbackCredential

public class ParraFeedback {
    internal static var shared: ParraFeedback = {
        let dataManager = ParraFeedbackDataManager()
        return ParraFeedback(
            dataManager: dataManager
        )
    }()
    internal private(set) var isInitialized = false
    internal let dataManager: ParraFeedbackDataManager
    var authenticationProvider: ParraFeedbackAuthenticationProvider?
    
    internal lazy var urlSession: URLSession = {
        return URLSession(configuration: .default)
    }()
    
    internal init(dataManager: ParraFeedbackDataManager) {
        self.dataManager = dataManager
        
        UIFont.registerFontsIfNeeded() // Needs to be called before any UI is displayed.
        
        addEventObservers()
    }
    
    deinit {
        // Being a good citizen. This should only happen when the singleton is destroyed when the
        // app is being killed anyway.
        removeEventObservers()
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
            print("\(ParraFeedback.Constants.parraLogPrefix) Error loading data: \(dataError)")
        }
    }
    
    // TODO: Do we really even need this???
    public class func logout() {
//        shared.dataManager.credentialStorage.updateCredential(credential: nil)
        // TODO: data manager clear all data.
    }
    
    public class func fetchFeedbackCards(completion: @escaping (ParraFeedbackError?) -> Void) {
        Task {
            do {
#if DEBUG
                try await Task.sleep(nanoseconds: 1_500_000_000)
#endif
                try await fetchFeedbackCards()
                
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion(ParraFeedbackError.dataLoadingError(error))
                }
            }
        }
    }
    
    public class func fetchFeedbackCards() async throws {
        let cardsResponse: CardsResponse = try await shared.performAuthenticatedRequest(
            route: "cards",
            method: .get,
            authenticationProvider: shared.refreshAuthentication
        )
        

        // Only keep cards that we don't already have an answer cached for. This isn't something that
        // should ever even happen, but in event that new cards are retreived that include cards we
        // already have an answer for, we'll keep the answered cards hidden and they'll be flushed
        // the next time a sync is triggered.
        var cardsToKeep = [CardItem]()

        for card in cardsResponse.items {
            switch card.data {
            case .question(let question):
                let answer = await shared.dataManager.answerData(forQuestion: question)
            
                if answer == nil {
                    cardsToKeep.append(card)
                }
            }
        }
                
        shared.dataManager.updateCards(cards: cardsToKeep)
    }    
}
