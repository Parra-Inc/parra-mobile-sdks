//
//  ParraCardView.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 11/23/21.
//

import UIKit

/// `ParraCardView`s are used to display cards fetched via the `ParraFeedback`
/// module. Fetching and displaying cards are decoupled to allow you the
/// flexibility to fetch cards asynchronously and only display them in your UI
/// when you're ready. Any cards that have been fetched in the `ParraFeedback`
/// module will automatically be displayed by `ParraCardView`s when they are
/// added to your view hierarchy.
public class ParraCardView: UIView {
    // MARK: - Lifecycle

    /// Creates a `ParraCardView`. If there are any `ParraCardItem`s available in hte `ParraFeedback` module,
    /// they will be displayed automatically when adding this view to your view hierarchy.
    public required init(
        config: ParraCardViewConfig = .default
    ) {
        self.config = config

        super.init(frame: .zero)

        answerHandler.questionHandlerDelegate = self

        addSubview(containerView)
        containerView.addSubview(navigationStack)
        addSubview(contentView)

        configureSubviews(config: config)
    }

    // MARK: - Public

    public enum Dimensions {
        public static let minWidth: CGFloat = 320
        public static let minHeight: CGFloat = 254
    }

    /// The object that acts as the delegate of the `ParraCardView`. The delegate is not retained.
    public weak var delegate: ParraCardViewDelegate?

    /// A `ParraCardViewConfig` used to configure how `ParraCardView`s look. Use this to make `ParraCardView`s
    /// blend in with the UI in the rest of your app.
    public var config: ParraCardViewConfig {
        didSet {
            applyConfig(config)
        }
    }

    // MARK: - Internal

    let answerHandler = ParraCardAnswerHandler()

    var currentCardInfo: CurrentCardInfo?

    var cardItems: [ParraCardItem] = [] {
        didSet {
            let existedPreviously = !oldValue.isEmpty

            if cardItems != oldValue {
                // If there is already a card item and that item exists in the updated cards list,
                // we want to make sure that item stays visible.
                if let currentCardInfo,
                   let currentCardItem = currentCardInfo.cardItem,
                   cardItems.contains(where: { $0.id == currentCardItem.id })
                {
                    let visibleButtons =
                        visibleNavigationButtonsForCardItem(currentCardItem)

                    UIView.animate(
                        withDuration: 0.375,
                        delay: 0.0,
                        options: [.curveEaseInOut, .beginFromCurrentState],
                        animations: {
                            self
                                .updateVisibleNavigationButtons(
                                    visibleButtons: visibleButtons
                                )
                        },
                        completion: nil
                    )
                } else {
                    transitionToNextCard(
                        direction: .right,
                        animated: existedPreviously
                    )
                }

                if existedPreviously, cardItems.isEmpty {
                    delegate?.parraCardViewDidCompleteCollection(self)
                }
            }
        }
    }
}
