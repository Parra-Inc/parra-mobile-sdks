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
        
        let networkManager = ParraFeedbackNetworkManager(
            dataManager: dataManager
        )
        
        let syncManager = ParraFeedbackSyncManager(
            dataManager: dataManager,
            networkManager: networkManager
        )
        
        return ParraFeedback(
            dataManager: dataManager,
            syncManager: syncManager,
            networkManager: networkManager
        )
    }()
    
    internal private(set) var isInitialized = false
    internal let dataManager: ParraFeedbackDataManager
    internal let syncManager: ParraFeedbackSyncManager
    internal let networkManager: ParraFeedbackNetworkManager
        
    internal init(dataManager: ParraFeedbackDataManager,
                  syncManager: ParraFeedbackSyncManager,
                  networkManager: ParraFeedbackNetworkManager) {
        
        self.dataManager = dataManager
        self.syncManager = syncManager
        self.networkManager = networkManager
        
        UIFont.registerFontsIfNeeded() // Needs to be called before any UI is displayed.
        
        addEventObservers()
        
        Task {
            await ensureInitialized()
        }
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
            parraLog("Error loading data: \(dataError)", level: .error)
        }
    }
    
    // TODO: Do we really even need this???
    public class func logout() {
        Task {
            await shared.dataManager.updateCredential(credential: nil)
        }
    }
    
    /// Uploads any cached Parra data. This includes data like answers to questions.
    public class func triggerSync() {
        Task {
            await shared.syncManager.enqueueSync()
        }
    }
    
    public class func fetchFeedbackCards(completion: @escaping ([CardItem], ParraFeedbackError?) -> Void) {
        Task {
            do {
                let cards = try await fetchFeedbackCards()
                
                DispatchQueue.main.async {
                    completion(cards, nil)
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion([], ParraFeedbackError.dataLoadingError(error))
                }
            }
        }
    }
    
    public class func fetchFeedbackCards() async throws -> [CardItem] {
        let cardsResponse: CardsResponse = try await shared.networkManager.performAuthenticatedRequest(
            route: "cards",
            method: .get
        )
        
        // Only keep cards that we don't already have an answer cached for. This isn't something that
        // should ever even happen, but in event that new cards are retreived that include cards we
        // already have an answer for, we'll keep the answered cards hidden and they'll be flushed
        // the next time a sync is triggered.
        var cardsToKeep = [CardItem]()

        for card in cardsResponse.items {
            switch card.data {
            case .question(let question):
                let cardData = await shared.dataManager.completedCardData(forId: question.id)
            
                if cardData == nil {
                    cardsToKeep.append(card)
                }
            }
        }
                
        shared.dataManager.updateCards(cards: cardsToKeep)
        
        return cardsToKeep
    }    
}
