//
//  ParraFeedback.swift
//  Feedback
//
//  Created by Mick MacCallum on 3/12/22.
//

import Foundation
import ParraCore

/// The `ParraFeedback` module is used to fetch Parra Feedback data from the Parra API. Once data is fetched,
/// it will be displayed automatically in any `ParraCardView`s that you add to your view hierarchy.
/// To handle authentication, see the Parra Core module.
public class ParraFeedback: ParraModule {
    internal static let shared = ParraFeedback()
    internal let dataManager = ParraFeedbackDataManager()
    
    private init() {
        Parra.registerModule(module: self)
    }
    
    public private(set) static var name: String = "Feedback"

    /// Fetch any available cards from the Parra API. Once cards are successfully fetched, they will automatically be cached by the `ParraFeedback`
    /// module and will be automatically displayed in `ParraCardView`s when they are added to your view hierarchy. The completion handler
    /// for this method contains a list of the card items that were recevied. If you'd like, you can filter them yourself and only pass select card items
    /// view the `ParraCardView` initializer if you'd like to only display certain cards.
    public class func fetchFeedbackCards(appArea: ParraQuestionAppArea = .all,
                                         withCompletion completion: @escaping (Result<[ParraCardItem], ParraError>) -> Void) {
        Task {
            do {
                let cards = try await fetchFeedbackCards(appArea: appArea)
                
                DispatchQueue.main.async {
                    completion(.success(cards))
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion(.failure(ParraError.custom("Error fetching Parra Feedback cards", error)))
                }
            }
        }
    }
    
    /// Fetch any available cards from the Parra API. Once cards are successfully fetched, they will automatically be cached by the `ParraFeedback`
    /// module and will be automatically displayed in `ParraCardView`s when they are added to your view hierarchy. The completion handler
    /// for this method contains a list of the card items that were recevied. If you'd like, you can filter them yourself and only pass select card items
    /// view the `ParraCardView` initializer if you'd like to only display certain cards.
    public class func fetchFeedbackCards(appArea: ParraQuestionAppArea = .all,
                                         withCompletion completion: @escaping ([ParraCardItem], Error?) -> Void) {
        fetchFeedbackCards(appArea: appArea) { result in
            switch result {
            case .success(let cards):
                completion(cards, nil)
            case .failure(let parraError):
                let error = NSError(
                    domain: ParraFeedback.errorDomain(),
                    code: 20,
                    userInfo: [
                        NSLocalizedDescriptionKey: parraError.localizedDescription
                    ]
                )
                
                completion([], error)
            }
        }
    }
    
    /// Fetch any available cards from the Parra API. Once cards are successfully fetched, they will automatically be cached by the `ParraFeedback`
    /// module and will be automatically displayed in `ParraCardView`s when they are added to your view hierarchy. The completion handler
    /// for this method contains a list of the card items that were recevied. If you'd like, you can filter them yourself and only pass select card items
    /// view the `ParraCardView` initializer if you'd like to only display certain cards.
    public class func fetchFeedbackCards(appArea: ParraQuestionAppArea = .all) async throws -> [ParraCardItem] {
        let cards = try await Parra.API.getCards(appArea: appArea)
        
        // Only keep cards that we don't already have an answer cached for. This isn't something that
        // should ever even happen, but in event that new cards are retreived that include cards we
        // already have an answer for, we'll keep the answered cards hidden and they'll be flushed
        // the next time a sync is triggered.
        var cardsToKeep = [ParraCardItem]()

        for card in cards {
            switch card.data {
            case .question(let question):
                let previouslyCleared = await shared.dataManager.hasClearedCompletedCardWithId(card: card)
                let cardData = await shared.dataManager.completedCardData(forId: question.id)
            
                if !previouslyCleared && cardData == nil {
                    cardsToKeep.append(card)
                }
            }
        }

        shared.performAssetPrefetch(for: cardsToKeep)
        shared.dataManager.setCards(cards: cardsToKeep)
        
        return cardsToKeep
    }

    /// Whether the `ParraFeedback` module has data that has yet to be synced with the Parra API.
    public func hasDataToSync() async -> Bool {
        let answers = await dataManager.currentCompletedCardData()

        return !answers.isEmpty
    }
    
    /// Triggers an immediate sync of any stored ParraFeedback data with the Parra API. Instead of using this method, you should prefer to call `Parra.triggerSync()`
    /// on the ParraCore module, which can better handle enqueuing multiple sync requests. Sync calls will automatically happen when:
    /// 1. Calling `Parra.logout()`
    /// 2. The application transitions to or from the active state.
    /// 3. There is a significant time change on the system clock.
    /// 4. All cards for a `ParraCardView` are completed.
    /// 5. A `ParraCardView` is deinitialized or removed from the view hierarchy.
    public func synchronizeData() async {
        await sendCardData()
    }
    
    /// Checks whether the user has previously supplied input for the provided `ParraCardItem`.
    public class func hasCardBeenCompleted(_ cardItem: ParraCardItem) async -> Bool {
        let completed = await shared.dataManager.completedCardData(forId: cardItem.id)
        
        return completed != nil
    }

    private func sendCardData() async {
        let completedCardData = await dataManager.currentCompletedCardData()
        let completedCards = Array(completedCardData.values)
        
        let completedChunks = completedCards.chunked(into: ParraFeedback.Constant.maxBulkAnswers)

        await withTaskGroup(of: Void.self) { group in
            for chunk in completedChunks {
                group.addTask {
                    do {
                        try await self.uploadCompletedCards(chunk)
                        try await self.dataManager.clearCompletedCardData(completedCards: chunk)
                        await self.dataManager.removeCardsForCompletedCards(completedCards: chunk)
                    } catch let error {
                        parraLogError(ParraError.custom("Error uploading card data", error))
                    }
                }
            }
        }
    }

    private func uploadCompletedCards(_ cards: [CompletedCard]) async throws {
        try await Parra.API.bulkAnswerQuestions(cards: cards)
    }

    private func performAssetPrefetch(for cards: [ParraCardItem]) {
        Task {
            parraLogDebug("Attempting asset prefetch for \(cards.count) card(s)...")
            let assets = cards.flatMap { $0.getAllAssets() }
            parraLogDebug("\(assets.count) asset(s) available for prefetching")


            await Parra.Assets.performBulkAssetCachingRequest(assets: assets)

            parraLogDebug("Completed prefetching assets")
        }
    }

    public func didReceiveSessionResponse(sessionResponse: ParraSessionsResponse) {
        Task {
            await pollForQuestions(context: sessionResponse)
        }
    }

    private func pollForQuestions(context: ParraSessionsResponse) async {
        parraLogDebug("Checking if polling for questions should occur")

        guard context.shouldPoll else {
            parraLogTrace("Should poll flag not set, skipping polling")
            return
        }

        // Success means the request didn't fail and there are cards in the response that have a display type popup or drawer
        for attempt in 0...context.retryTimes {
            do {
                parraLogTrace("Fetching cards. Attempt #\(attempt + 1)")

                let cards = try await getCardsForPresentation()

                if cards.isEmpty {
                    parraLogTrace(
                        "No cards found. Retrying \(context.retryTimes - attempt) more time(s). Next attempt in \(context.retryDelay)ms"
                    )

                    try await Task.sleep(ms: context.retryDelay)

                    continue
                }

                let validPopupCards = cards.filter { cardItem in
                    // TODO: Filter card items without an app area.
                    return cardItem.displayType == .drawer || cardItem.displayType == .popup
                }

                displayPopupCards(cardItems: validPopupCards)
            } catch let error {
                parraLogError("Encountered error fetching cards. Cancelling polling.", error)
            }
        }
    }

    private func displayPopupCards(cardItems: [ParraCardItem]) {
        parraLogTrace("Displaying popup cards")

        guard !cardItems.isEmpty else {
            parraLogTrace("Skipping presenting popup. No valid cards")
            return
        }

        // Take the displayType of the first card and use that to deterine the modal style.
        guard let displayType = cardItems.first?.displayType else {
            parraLogTrace("Skipping presenting popup. No displayType set")

            return
        }

        switch displayType {
        case .popup:
            ParraFeedback.presentCardPopup(
                with: cardItems,
                fromViewController: nil,
                config: .default,
                transitionStyle: .slide
            )
        case .drawer:
            if #available(iOS 15.0, *) {
                ParraFeedback.presentCardDrawer(
                    with: cardItems,
                    fromViewController: nil,
                    config: .default
                )
            } else {
                parraLogTrace("Drawer displayType not available on current iOS version. Using popup style instead.")
                ParraFeedback.presentCardPopup(
                    with: cardItems,
                    fromViewController: nil,
                    config: .default,
                    transitionStyle: .slide
                )
            }
        default:
            parraLogTrace("Skipping presenting popup. displayType \(displayType) is not a valid modal type")
        }
    }

    private func getCardsForPresentation() async throws -> [ParraCardItem] {
        let cards = try await Parra.API.getCards(appArea: .none)

        return cards.filter {
            $0.displayType == .popup || $0.displayType == .drawer
        }
    }
}
