//
//  ParraFeedback.swift
//  Feedback
//
//  Created by Mick MacCallum on 3/12/22.
//

import Foundation

private let logger = Logger(category: "Feedback module")

/// The `ParraFeedback` module is used to fetch Parra Feedback data from the
/// Parra API. Once data is fetched, it will be displayed automatically in any
/// `ParraCardView`s that you add to your view hierarchy. To handle
/// authentication, see the Parra module.
public class ParraFeedback {
    // MARK: - Lifecycle

    init(
        dataManager: ParraFeedbackDataManager,
        networkManager: ParraNetworkManager
    ) {
        self.dataManager = dataManager
        self.networkManager = networkManager
    }

    // MARK: - Public

    public static var shared: ParraFeedback! {
//        return Parra.getExistingInstance().feedback
        return nil
    }

    /// Fetch any available cards from the Parra API. Once cards are
    /// successfully fetched, they will automatically be cached by the
    /// `ParraFeedback` module and will be automatically displayed in
    /// `ParraCardView`s when they are added to your view hierarchy. The
    /// completion handler for this method contains a list of the card items
    /// that were recevied. If you'd like, you can filter them yourself and only
    /// pass select card items view the `ParraCardView` initializer if you'd
    /// like to only display certain cards.
    public func fetchFeedbackCards(
        appArea: ParraQuestionAppArea = .all,
        withCompletion completion: @escaping (Result<
            [ParraCardItem],
            ParraError
        >) -> Void
    ) {
        Task {
            do {
                let cards = try await fetchFeedbackCards(appArea: appArea)

                DispatchQueue.main.async {
                    completion(.success(cards))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(ParraError.generic(
                        "Error fetching Parra Feedback cards",
                        error
                    )))
                }
            }
        }
    }

    /// Fetch any available cards from the Parra API. Once cards are
    /// successfully fetched, they will automatically be cached by the
    /// `ParraFeedback` module and will be automatically displayed in
    /// `ParraCardView`s when they are added to your view hierarchy. The
    /// completion handler for this method contains a list of the card items
    /// that were recevied. If you'd like, you can filter them yourself and only
    /// pass select card items view the `ParraCardView` initializer if you'd
    ///  like to only display certain cards.
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
                    domain: ParraInternal.errorDomain,
                    code: 20,
                    userInfo: [
                        NSLocalizedDescriptionKey: parraError
                            .localizedDescription
                    ]
                )

                completion([], error)
            }
        }
    }

    /// Fetch any available cards from the Parra API. Once cards are
    /// successfully fetched, they will automatically be cached by the
    /// `ParraFeedback` module and will be automatically displayed in
    /// `ParraCardView`s when they are added to your view hierarchy. The
    /// completion handler for this method contains a list of the card items
    /// that were recevied. If you'd like, you can filter them yourself and only
    /// pass select card items view the `ParraCardView` initializer if you'd
    /// like to only display certain cards.
    public func fetchFeedbackCards(
        appArea: ParraQuestionAppArea = .all
    ) async throws -> [ParraCardItem] {
        let cardsResponse = try await networkManager.getCards(
            appArea: appArea
        )
        let cards = cardsResponse.items

        // Only keep cards that we don't already have an answer cached for. This
        // isn't something that should ever even happen, but in event that new
        // cards are retreived that include cards we already have an answer for,
        // we'll keep the answered cards hidden and they'll be flushed the next
        // time a sync is triggered.
        var cardsToKeep = [ParraCardItem]()

        for card in cards {
            if await cachedCardPredicate(card: card) {
                cardsToKeep.append(card)
            }
        }

        applyNewCards(cards: cardsToKeep)

        return cardsToKeep
    }

    /// Fetches the feedback form with the provided ID from the Parra API.
    /// If a form is returned, it is up to the caller to pass this response to
    /// `ParraFeedback.presentFeedbackForm` to present the feedback form.
    /// Splitting up feedback form presentation in this way allows us to skip
    /// having to show loading indicators.
    public func fetchFeedbackForm(
        formId: String
    ) async throws -> ParraFeedbackForm {
        let response = try await networkManager.getFeedbackForm(with: formId)

        return ParraFeedbackForm(from: response)
    }

    /// Fetches the feedback form with the provided ID from the Parra API. If a
    /// form is returned, it is up to the caller to pass this response to
    /// `ParraFeedback.presentFeedbackForm` to present the feedback form.
    /// Splitting up feedback form presentation in this way allows us to skip
    /// having to show loading indicators.
    public func fetchFeedbackForm(
        formId: String,
        withCompletion completion: @escaping (Result<
            ParraFeedbackForm,
            ParraError
        >) -> Void
    ) {
        Task {
            do {
                let response = try await fetchFeedbackForm(
                    formId: formId
                )

                DispatchQueue.main.async {
                    completion(.success(response))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(
                        .failure(ParraError.generic(
                            "Error fetching Parra Feedback form: \(formId)",
                            error
                        ))
                    )
                }
            }
        }
    }

    // MARK: - Internal

    let dataManager: ParraFeedbackDataManager
    let networkManager: ParraNetworkManager

    /// Checks whether the user has previously supplied input for the provided
    /// `ParraCardItem`.
    func hasCardBeenCompleted(
        _ cardItem: ParraCardItem
    ) async -> Bool {
        let completed = await dataManager.completedCardData(
            forId: cardItem.id
        )

        return completed != nil
    }

    func didReceiveSessionResponse(
        sessionResponse: ParraSessionsResponse
    ) {
        Task {
            let isPopupPresent = await ParraFeedbackPopupState.shared
                .isPresented

            if isPopupPresent {
                logger
                    .debug(
                        "Skipping polling for questions. Popup currently open."
                    )
            } else {
                await pollForQuestions(context: sessionResponse)
            }
        }
    }

    // MARK: - Private

    private func performAssetPrefetch(
        for cards: [ParraCardItem]
    ) {
        if cards.isEmpty {
            return
        }

        Task {
            logger
                .debug(
                    "Attempting asset prefetch for \(cards.count) card(s)..."
                )
            let assets = cards.flatMap { $0.getAllAssets() }

            if assets.isEmpty {
                logger.debug("No assets are available for prefetching")

                return
            }

            logger.debug("\(assets.count) asset(s) available for prefetching")

            await networkManager.performBulkAssetCachingRequest(
                assets: assets
            )

            logger.debug("Completed prefetching assets")
        }
    }

    private func pollForQuestions(
        context: ParraSessionsResponse
    ) async {
        logger.debug("Checking if polling for questions should occur")

        guard context.shouldPoll else {
            logger.trace("Should poll flag not set, skipping polling")
            return
        }

        // Success means the request didn't fail and there are cards in the
        // response that have a display type popup or drawer
        for attempt in 0 ... context.retryTimes {
            do {
                logger.trace("Fetching cards. Attempt #\(attempt + 1)")

                let cards = try await getCardsForPresentation()

                if cards.isEmpty {
                    logger.trace(
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
            } catch {
                logger.error(
                    "Encountered error fetching cards. Cancelling polling.",
                    error
                )
            }
        }
    }

    private func displayPopupCards(cardItems: [ParraCardItem]) {
        logger.trace("Displaying popup cards")

        guard !cardItems.isEmpty else {
            logger.trace("Skipping presenting popup. No valid cards")
            return
        }

        // Take the display type of the first card that has one set as the
        // display type to use for this set of cards.
        // It is unlikely there will ever be a case where this isn't found on
        // the first element.
        guard let displayType = cardItems.first(
            where: { $0.displayType != nil }
        )?.displayType else {
            logger.trace("Skipping presenting popup. No displayType set")

            return
        }

//        let onDismiss: () -> Void = {
//            Task {
//                await ParraFeedbackPopupState.shared.dismiss()
//            }
//        }

        switch displayType {
        case .popup:
            Task {
                await ParraFeedbackPopupState.shared.present()
            }

//            presentCardPopup(
//                with: cardItems,
//                from: nil,
//                config: .default,
//                transitionStyle: .slide,
//                // In this context the user isn't allowed to dismiss the modal manually. It will be auto-
//                // dismissed when they complete the cards.
//                userDismissable: false,
//                onDismiss: onDismiss
//            )
        default:
            logger
                .trace(
                    "Skipping presenting popup. displayType \(displayType) is not a valid modal type"
                )
        }
    }

    private func getCardsForPresentation() async throws -> [ParraCardItem] {
        let cardsResponse = try await networkManager.getCards(
            appArea: .none
        )
        let cards = cardsResponse.items

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
            let previouslyCleared = await dataManager
                .hasClearedCompletedCardWithId(
                    card: card
                )

            let cardData = await dataManager.completedCardData(
                forId: question.id
            )

            if !previouslyCleared, cardData == nil {
                return true
            }

            return false
        }
    }
}
