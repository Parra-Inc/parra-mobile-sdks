//
//  ParraCardView.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 11/23/21.
//

import UIKit
import ParraCore

/// A delegate for `ParraCardView`s that allows for additional customization, and to be informed of actions
/// such as when particular cards are displayed or when all questions are answered.
public protocol ParraCardViewDelegate: AnyObject {
    
    /// Asks the delegate to provide a view that the provided `ParraCardView` can display when all cards
    /// have been completed.
    ///
    /// - Parameter parraCardView: A `ParraCardView` asking the delegate for a complete state view.
    /// - Returns: A `UIView` shown within the `ParraCardView` when it is in its complete state.
    func completeStateViewForParraCardView(_ parraCardView: ParraCardView) -> UIView?
    
    
    /// Tells the delegate that every card on the `ParraCardView` has been completed.
    ///
    /// This delegate method can be useful for hiding the ParraCardView, since all available cards have been completed.
    ///
    /// - Parameter parraCardView: A `ParraCardView` informing the delegate about the collection completion
    func parraCardViewDidCompleteCollection(_ parraCardView: ParraCardView)
    
    
    /// Tells the delegate that the `ParraCardView` is about to display the provided `CardItem`.
    /// If no card item is provided, the `ParraCardView` is transitioning to the complete state.
    /// - Parameters:
    ///   - parraCardView: A `ParraCardView` informing the delegate about the card transition.
    ///   - cardItem: The `CardItem` displayed on the card that is about to be displayed.
    func parraCardView(_ parraCardView: ParraCardView,
                           willDisplay cardItem: ParraCardItem?)
    
    
    /// Tells the delegate that the `ParraCardView` is displaying the provided `CardItem`.
    /// If no card item is provided, the `ParraCardView` is transitioning to the complete state.
    /// - Parameters:
    ///   - parraCardView: A `ParraCardView` informing the delegate about the card transition.
    ///   - cardItem: The `CardItem` displayed on the card that is now being displayed.
    func parraCardView(_ parraCardView: ParraCardView,
                           didDisplay cardItem: ParraCardItem?)
    
    
    /// Tells the delegate that the `ParraCardView` is about to stop displaying the provided `CardItem`.
    /// If no card item is provided, the `ParraCardView` is transitioning from the complete state.
    /// - Parameters:
    ///   - parraCardView: A `ParraCardView` informing the delegate about the card transition.
    ///   - cardItem: The `CardItem` displayed on the card that will no longer be displayed.
    func parraCardView(_ parraCardView: ParraCardView,
                           willEndDisplaying cardItem: ParraCardItem?)
    
    
    /// Tells the delegate that the `ParraCardView` has stopped displaying the provided `CardItem`.
    /// If no card item is provided, the `ParraCardView` is transitioning from the complete state.
    /// - Parameters:
    ///   - parraCardView: A `ParraCardView` informing the delegate about the card transition.
    ///   - cardItem: The `CardItem` displayed on the card that is no longer displayed.
    func parraCardView(_ parraCardView: ParraCardView,
                           didEndDisplaying cardItem: ParraCardItem?)
    
    
    /// Asks the delegate whether or not it should automatically navigate to the provided `CardItem`. This occurs
    /// when the user makes a selection on a card that marks is as complete for the first time and there is a next card
    /// available to transition to.
    ///
    /// - Parameters:
    ///   - parraCardView: The `ParraCardView` asking the delegate whether or not to navigate
    ///                        to the supplied `CardItem`.
    ///   - cardItem: The `CardItem` that will be displayed on the next card.
    /// - Returns: A `Bool` indicating whether or not the automatic navigation should occur.
    func parraCardView(_ parraCardView: ParraCardView,
                           shouldAutoNavigateTo cardItem: ParraCardItem) -> Bool


    /// The ParraCardView has received answers for all of its cards and the user has selected the dismiss option.
    /// Use this event to change any conditional rendering of the ParraCardView to dismiss it from view.
    ///   - parraCardView: A `ParraCardView` informing the delegate dismissal request.
    func parraCardViewDidRequestDismissal(_ parraCardView: ParraCardView)
}

public extension ParraCardViewDelegate {
    func parraCardViewDidCompleteCollection(_ parraCardView: ParraCardView) {}
    
    func parraCardView(_ parraCardView: ParraCardView,
                           willDisplay cardItem: ParraCardItem?) {}
    
    func parraCardView(_ parraCardView: ParraCardView,
                           didDisplay cardItem: ParraCardItem?) {}
    
    func parraCardView(_ parraCardView: ParraCardView,
                           willEndDisplaying cardItem: ParraCardItem?) {}
    
    func parraCardView(_ parraCardView: ParraCardView,
                           didEndDisplaying cardItem: ParraCardItem?) {}
    
    func parraCardView(_ parraCardView: ParraCardView,
                           shouldAutoNavigateTo cardItem: ParraCardItem) -> Bool {
        return true
    }
    
    func completeStateViewForParraCardView(_ parraCardView: ParraCardView) -> UIView? {
        return nil
    }

    func parraCardViewDidRequestDismissal(_ parraCardView: ParraCardView) {
        parraCardViewDidCompleteCollection(parraCardView)
    }
}

/// `ParraCardView`s are used to display cards fetched via the `ParraCardView` module. Fetching and displaying
/// cards are decoupled to allow you the flexibility to fetch cards asynchronously and only display them in your UI when you're
/// ready. Any cards that have been fetched in the `ParraFeedback` module will automatically be displayed by
/// `ParraCardView`s when they are added to your view hierarchy.
public class ParraCardView: UIView {
    public enum Dimensions {
        public static let minWidth: CGFloat = 320
        public static let minHeight: CGFloat = 274
    }
    
    /// The object that acts as the delegate of the `ParraCardView`. The delegate is not retained.
    public weak var delegate: ParraCardViewDelegate?
    
    internal let questionHandler = ParraQuestionHandler()
    
    internal var cardItems: [ParraCardItem] = [] {
        didSet {
            let existedPreviously = !oldValue.isEmpty
            
            if cardItems != oldValue {
                // If there is already a card item and that item exists in the updated cards list,
                // we want to make sure that item stays visible.
                if let currentCardInfo = currentCardInfo,
                    let currentCardItem = currentCardInfo.cardItem, cardItems.contains(where: { $0.id == currentCardItem.id }) {
                } else {
                    transitionToNextCard(direction: .right, animated: existedPreviously)
                }
                
                if existedPreviously && cardItems.isEmpty {
                    delegate?.parraCardViewDidCompleteCollection(self)
                }
            }
        }
    }
    
    internal var currentCardInfo: CurrentCardInfo?
    
    internal var constraintsOnSuperView = [NSLayoutConstraint]()
    
    internal var containerLeadingConstraint: NSLayoutConstraint!
    internal var containerTrailingConstraint: NSLayoutConstraint!
    internal var containerTopConstraint: NSLayoutConstraint!
    internal var containerBottomConstraint: NSLayoutConstraint!
    
    internal var constraintsOncontainerView: [NSLayoutConstraint] {
        return [
            containerLeadingConstraint, containerTrailingConstraint, containerTopConstraint, containerBottomConstraint
        ]
    }
    
    internal var currentCardConstraint: NSLayoutConstraint?
    
    internal let containerView = UIView(frame: .zero)
    internal let contentView = UIView(frame: .zero)
    
    /// A `ParraCardViewConfig` used to configure how `ParraCardView`s look. Use this to make `ParraCardView`s
    /// blend in with the UI in the rest of your app.
    public var config: ParraCardViewConfig {
        didSet {
            applyConfig(config)
        }
    }

    internal let poweredByButton = UIButton(type: .system)
    internal lazy var navigationStack: UIStackView = ({
        return UIStackView(arrangedSubviews: [
            poweredByButton
        ])
    })()

    /// Creates a `ParraCardView`. If there are any `ParraCardItem`s available in hte `ParraFeedback` module,
    /// they will be displayed automatically when adding this view to your view hierarchy.
    public required init(
        config: ParraCardViewConfig = .default
    ) {
        self.config = config
        
        super.init(frame: .zero)
        
        questionHandler.questionHandlerDelegate = self
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        layer.masksToBounds = false
        setContentHuggingPriority(.init(rawValue: 999), for: .horizontal)
        setContentHuggingPriority(.defaultHigh, for: .vertical)
        accessibilityIdentifier = "ParraCardView"
        
        addSubview(containerView)
        containerView.addSubview(navigationStack)
        addSubview(contentView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.masksToBounds = true
        containerView.isUserInteractionEnabled = true
        containerView.accessibilityIdentifier = "ParraFeedbackContainerView"
        
        configureSubviews(config: config)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Parra.triggerSync()
    }
    
    public override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        if newWindow == nil {
            NotificationCenter.default.removeObserver(self,
                                                      name: ParraFeedback.cardsDidChangeNotification,
                                                      object: nil)
            
            Parra.triggerSync()
        } else {
            checkAndUpdateCards()
        }
    }
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveCardChangeNotification(notification:)),
                                               name: ParraFeedback.cardsDidChangeNotification,
                                               object: nil)
    }
    
    @objc private func didReceiveCardChangeNotification(notification: Notification) {
        checkAndUpdateCards()
    }
    
    private func checkAndUpdateCards() {
        Task {
            let newCards = await ParraFeedback.shared.dataManager.currentCards()
            
            await MainActor.run {
                cardItems = newCards
            }
        }
    }
}
