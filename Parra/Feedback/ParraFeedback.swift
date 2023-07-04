//
//  ParraFeedback.swift
//  Feedback
//
//  Created by Mick MacCallum on 3/12/22.
//

import Foundation

/// The `ParraFeedback` module is used to fetch Parra Feedback data from the Parra API. Once data is fetched,
/// it will be displayed automatically in any `ParraCardView`s that you add to your view hierarchy.
/// To handle authentication, see the Parra module.
public class ParraFeedback: ParraModule {
    internal let parra: Parra
    internal let dataManager: ParraFeedbackDataManager

    public static var shared: ParraFeedback {
        return Parra.shared.feedback
    }

    internal init(
        parra: Parra,
        dataManager: ParraFeedbackDataManager
    ) {
        self.parra = parra
        self.dataManager = dataManager
    }

    internal private(set) static var name: String = "Feedback"

    /// Fetch any available cards from the Parra API. Once cards are successfully fetched, they will automatically be cached by the `ParraFeedback`
    /// module and will be automatically displayed in `ParraCardView`s when they are added to your view hierarchy. The completion handler
    /// for this method contains a list of the card items that were recevied. If you'd like, you can filter them yourself and only pass select card items
    /// view the `ParraCardView` initializer if you'd like to only display certain cards.
    public func fetchFeedbackCards(
        appArea: ParraQuestionAppArea = .all,
        withCompletion completion: @escaping (Result<[ParraCardItem], ParraError>) -> Void
    ) {
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
    public func fetchFeedbackCards(
        appArea: ParraQuestionAppArea = .all,
        withCompletion completion: @escaping ([ParraCardItem], Error?) -> Void
    ) {
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
    public func fetchFeedbackCards(
        appArea: ParraQuestionAppArea = .all
    ) async throws -> [ParraCardItem] {
        let cards = try await parra.networkManager.getCards(appArea: appArea)
        
        // Only keep cards that we don't already have an answer cached for. This isn't something that
        // should ever even happen, but in event that new cards are retreived that include cards we
        // already have an answer for, we'll keep the answered cards hidden and they'll be flushed
        // the next time a sync is triggered.
        var cardsToKeep = [ParraCardItem]()

        for card in cards {
            if await cachedCardPredicate(card: card) {
                cardsToKeep.append(card)
            }
        }

        applyNewCards(cards: cardsToKeep)
        
        return cardsToKeep
    }

    /// Fetches the feedback form with the provided ID from the Parra API. If a form is returned, it is up to the caller
    /// to pass this response to `ParraFeedback.presentFeedbackForm` to present the feedback form. Splitting up feedback
    /// form presentation in this way allows us to skip having to show loading indicators.
    public func fetchFeedbackForm(
        formId: String
    ) async throws -> ParraFeedbackFormResponse {
        return try await parra.networkManager.getFeedbackForm(with: formId)
    }

    /// Fetches the feedback form with the provided ID from the Parra API. If a form is returned, it is up to the caller
    /// to pass this response to `ParraFeedback.presentFeedbackForm` to present the feedback form. Splitting up feedback
    /// form presentation in this way allows us to skip having to show loading indicators.
    public func fetchFeedbackForm(
        formId: String,
        withCompletion completion: @escaping (Result<ParraFeedbackFormResponse, ParraError>) -> Void
    ) {
        Task {
            do {
                let response = try await fetchFeedbackForm(formId: formId)

                DispatchQueue.main.async {
                    completion(.success(response))
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion(
                        .failure(ParraError.custom("Error fetching Parra Feedback form: \(formId)", error))
                    )
                }
            }
        }
    }

    /// Whether the `ParraFeedback` module has data that has yet to be synced with the Parra API.
    internal func hasDataToSync() async -> Bool {
        let answers = await dataManager.currentCompletedCardData()

        return !answers.isEmpty
    }
    
    /// Triggers an immediate sync of any stored ParraFeedback data with the Parra API. Instead of using this method, you should prefer to call `Parra.triggerSync()`
    /// on the Parra module, which can better handle enqueuing multiple sync requests. Sync calls will automatically happen when:
    /// 1. Calling `Parra.logout()`
    /// 2. The application transitions to or from the active state.
    /// 3. There is a significant time change on the system clock.
    /// 4. All cards for a `ParraCardView` are completed.
    /// 5. A `ParraCardView` is deinitialized or removed from the view hierarchy.
    internal func synchronizeData() async throws {
        try await sendCardData()
    }
    
    /// Checks whether the user has previously supplied input for the provided `ParraCardItem`.
    internal func hasCardBeenCompleted(_ cardItem: ParraCardItem) async -> Bool {
        let completed = await dataManager.completedCardData(forId: cardItem.id)
        
        return completed != nil
    }

    // Need to bubble up sync failures to attempt backoff in sync manager if uploads are failing.
    private func sendCardData() async throws {
        let completedCardData = await dataManager.currentCompletedCardData()
        let completedCards = Array(completedCardData.values)
        
        let completedChunks = completedCards.chunked(into: ParraFeedback.Constant.maxBulkAnswers)

        for chunk in completedChunks {
            do {
                try await self.uploadCompletedCards(chunk)
                try await self.dataManager.clearCompletedCardData(completedCards: chunk)
                await self.dataManager.removeCardsForCompletedCards(completedCards: chunk)
            } catch let error {
                parraLogError(ParraError.custom("Error uploading card data", error))

                throw error
            }
        }
    }

    private func uploadCompletedCards(_ cards: [CompletedCard]) async throws {
        try await parra.networkManager.bulkAnswerQuestions(cards: cards)
    }

    private func performAssetPrefetch(for cards: [ParraCardItem]) {
        if cards.isEmpty {
            return
        }

        Task {
            parraLogDebug("Attempting asset prefetch for \(cards.count) card(s)...")
            let assets = cards.flatMap { $0.getAllAssets() }

            if assets.isEmpty {
                parraLogDebug("No assets are available for prefetching")

                return
            }

            parraLogDebug("\(assets.count) asset(s) available for prefetching")


            await parra.networkManager.performBulkAssetCachingRequest(assets: assets)

            parraLogDebug("Completed prefetching assets")
        }
    }

    internal func didReceiveSessionResponse(sessionResponse: ParraSessionsResponse) {
        Task {
            let isPopupPresent = await ParraFeedbackPopupState.shared.isPresented
            if isPopupPresent {
                parraLogDebug("Skipping polling for questions. Popup currently open.")
            } else {
                await pollForQuestions(context: sessionResponse)
            }
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
                } else {
                    applyNewCards(cards: cards)

                    DispatchQueue.main.async {
                        self.displayPopupCards(cardItems: cards)
                    }

                    break
                }
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

        // Take the display type of the first card that has one set as the display type to use for this set of cards.
        // It is unlikely there will ever be a case where this isn't found on the first element.
        guard let displayType = cardItems.first(where: { $0.displayType != nil })?.displayType else {
            parraLogTrace("Skipping presenting popup. No displayType set")

            return
        }

        let onDismiss: () -> Void = {
            Task {
                await ParraFeedbackPopupState.shared.dismiss()
            }
        }

        switch displayType {
        case .popup:
            Task {
                await ParraFeedbackPopupState.shared.present()
            }

            presentCardPopup(
                with: cardItems,
                from: nil,
                config: .default,
                transitionStyle: .slide,
                // In this context the user isn't allowed to dismiss the modal manually. It will be auto-
                // dismissed when they complete the cards.
                userDismissable: false,
                onDismiss: onDismiss
            )
        default:
            parraLogTrace("Skipping presenting popup. displayType \(displayType) is not a valid modal type")
        }
    }

    private func getCardsForPresentation() async throws -> [ParraCardItem] {
        let cards = try await parra.networkManager.getCards(appArea: .none)

        var validCards = [ParraCardItem]()
        for card in cards {
            // TODO: Filter card items without an app area.
            guard card.displayType == .drawer || card.displayType == .popup else {
                continue
            }

            guard await cachedCardPredicate(card: card) else {
                continue
            }

            validCards.append(card)
        }

        return validCards
    }

    private func applyNewCards(cards: [ParraCardItem]) {
        performAssetPrefetch(for: cards)
        dataManager.setCards(cards: cards)
    }

    private func cachedCardPredicate(card: ParraCardItem) async -> Bool {
        switch card.data {
        case .question(let question):
            let previouslyCleared = await dataManager.hasClearedCompletedCardWithId(card: card)
            let cardData = await dataManager.completedCardData(forId: question.id)

            if !previouslyCleared && cardData == nil {
                return true
            }

            return false
        }
    }
}
