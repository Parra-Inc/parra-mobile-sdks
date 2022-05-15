//
//  ParraFeedbackView.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 11/23/21.
//

import UIKit
import ParraCore

public protocol ParraFeedbackViewDelegate: AnyObject {
    
    /// Asks the delegate to provide a view that the provided `ParraFeedbackView` can display when all cards
    /// have been completed.
    ///
    /// - Parameter parraFeedbackView: A `ParraFeedbackView` asking the delegate for a complete state view.
    /// - Returns: A `UIView` shown within the `ParraFeedbackView` when it is in its complete state.
    func completeStateViewForParraFeedbackView(_ parraFeedbackView: ParraFeedbackView) -> UIView?
    
    
    /// Tells the delegate that every card on the `ParraFeedbackView` has been completed.
    ///
    /// This delegate method can be useful for hiding the ParraFeedbackView, since all available cards have been completed.
    ///
    /// - Parameter parraFeedbackView: A `ParraFeedbackView` informing the delegate about the collection completion
    func parraFeedbackViewDidCompleteCollection(_ parraFeedbackView: ParraFeedbackView)
    
    
    /// Tells the delegate that the `ParraFeedbackView` is about to display the provided `CardItem`.
    /// If no card item is provided, the `ParraFeedbackView` is transitioning to the complete state.
    /// - Parameters:
    ///   - parraFeedbackView: A `ParraFeedbackView` informing the delegate about the card transition.
    ///   - cardItem: The `CardItem` displayed on the card that is about to be displayed.
    func parraFeedbackView(_ parraFeedbackView: ParraFeedbackView,
                           willDisplay cardItem: CardItem?)
    
    
    /// Tells the delegate that the `ParraFeedbackView` is displaying the provided `CardItem`.
    /// If no card item is provided, the `ParraFeedbackView` is transitioning to the complete state.
    /// - Parameters:
    ///   - parraFeedbackView: A `ParraFeedbackView` informing the delegate about the card transition.
    ///   - cardItem: The `CardItem` displayed on the card that is now being displayed.
    func parraFeedbackView(_ parraFeedbackView: ParraFeedbackView,
                           didDisplay cardItem: CardItem?)
    
    
    /// Tells the delegate that the `ParraFeedbackView` is about to stop displaying the provided `CardItem`.
    /// If no card item is provided, the `ParraFeedbackView` is transitioning from the complete state.
    /// - Parameters:
    ///   - parraFeedbackView: A `ParraFeedbackView` informing the delegate about the card transition.
    ///   - cardItem: The `CardItem` displayed on the card that will no longer be displayed.
    func parraFeedbackView(_ parraFeedbackView: ParraFeedbackView,
                           willEndDisplaying cardItem: CardItem?)
    
    
    /// Tells the delegate that the `ParraFeedbackView` has stopped displaying the provided `CardItem`.
    /// If no card item is provided, the `ParraFeedbackView` is transitioning from the complete state.
    /// - Parameters:
    ///   - parraFeedbackView: A `ParraFeedbackView` informing the delegate about the card transition.
    ///   - cardItem: The `CardItem` displayed on the card that is no longer displayed.
    func parraFeedbackView(_ parraFeedbackView: ParraFeedbackView,
                           didEndDisplaying cardItem: CardItem?)
    
    
    /// Asks the delegate whether or not it should automatically navigate to the provided `CardItem`. This occurs
    /// when the user makes a selection on a card that marks is as complete for the first time and there is a next card
    /// available to transition to.
    ///
    /// - Parameters:
    ///   - parraFeedbackView: The `ParraFeedbackView` asking the delegate whether or not to navigate
    ///                        to the supplied `CardItem`.
    ///   - cardItem: The `CardItem` that will be displayed on the next card.
    /// - Returns: A `Bool` indicating whether or not the automatic navigation should occur.
    func parraFeedbackView(_ parraFeedbackView: ParraFeedbackView,
                           shouldAutoNavigateTo cardItem: CardItem) -> Bool
}

extension ParraFeedbackViewDelegate {
    func completeStateViewForParraFeedbackView(_ parraFeedbackView: ParraFeedbackView) -> UIView? {
        return nil
    }
    
    func parraFeedbackViewDidCompleteCollection(_ parraFeedbackView: ParraFeedbackView) {}
    
    func parraFeedbackView(_ parraFeedbackView: ParraFeedbackView,
                           willDisplay cardItem: CardItem?) {}
    
    func parraFeedbackView(_ parraFeedbackView: ParraFeedbackView,
                           didDisplay cardItem: CardItem?) {}
    
    func parraFeedbackView(_ parraFeedbackView: ParraFeedbackView,
                           willEndDisplaying cardItem: CardItem?) {}

    func parraFeedbackView(_ parraFeedbackView: ParraFeedbackView,
                           didEndDisplaying cardItem: CardItem?) {}
    
    func parraFeedbackView(_ parraFeedbackView: ParraFeedbackView,
                           shouldAutoNavigateTo cardItem: CardItem) -> Bool {
        return true
    }
}


/// <#Description#>
public class ParraFeedbackView: UIView {
    
    /// The object that acts as the delegate of the `ParraFeedbackView`. The delegate is not retained.
    public weak var delegate: ParraFeedbackViewDelegate?
    
    /// Whether or not swipe gestures can be used to transition between cards.
    public var areSwipeGesturesEnabled = true {
        didSet {
            for swipe in cardSwipeGestureRecognizers {
                swipe.isEnabled = areSwipeGesturesEnabled
            }
        }
    }
    internal var cardSwipeGestureRecognizers = [UISwipeGestureRecognizer]()
    
    internal let questionHandler = ParraQuestionHandler()
    
    internal var cardItems: [CardItem] {
        didSet {
            let existedPreviously = !oldValue.isEmpty
            
            if cardItems != oldValue {
                transitionToNextCard(direction: .right, animated: existedPreviously)
                
                if existedPreviously && cardItems.isEmpty {
                    delegate?.parraFeedbackViewDidCompleteCollection(self)
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
    
    internal let containerView = UIView(frame: .zero)
    internal let contentView = UIView(frame: .zero)
    
    /// <#Description#>
    public var config: ParraFeedbackViewConfig {
        didSet {
            applyConfig(config)
        }
    }
    
    /// The image used for the back button used to transition to the previous card. By default, a left facing arrow.
    public var backButtonImage: UIImage = UIImage(systemName: "arrow.left")! {
        didSet {
            backButton.setImage(backButtonImage, for: .normal)
        }
    }
    
    /// The image used for the forward button used to transition to the next card. By default, a right facing arrow.
    public var forwardButtonImage: UIImage = UIImage(systemName: "arrow.right")! {
        didSet {
            forwardButton.setImage(forwardButtonImage, for: .normal)
        }
    }
    
    internal lazy var backButton: UIButton = {
        return UIButton.systemButton(
            with: self.backButtonImage,
            target: self,
            action: #selector(navigateToPreviousCard)
        )
    }()
    internal lazy var forwardButton: UIButton = {
        return UIButton.systemButton(
            with: self.forwardButtonImage,
            target: self,
            action: #selector(navigateToNextCard)
        )
    }()
    internal let poweredByLabel = UILabel(frame: .zero)
    internal lazy var navigationStack: UIStackView = ({
        return UIStackView(arrangedSubviews: [
            backButton, poweredByLabel, forwardButton
        ])
    })()
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - cardItems: <#cardItems description#>
    ///   - config: <#config description#>
    public required init(
        cardItems: [CardItem] = [],
        config: ParraFeedbackViewConfig = .default
    ) {
        self.cardItems = cardItems
        self.config = config
        
        super.init(frame: .zero)
        
        questionHandler.questionHandlerDelegate = self
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        layer.masksToBounds = false
        setContentHuggingPriority(.defaultHigh, for: .horizontal)
        setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        addSubview(containerView)
        containerView.addSubview(navigationStack)
        addSubview(contentView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.masksToBounds = true
        containerView.isUserInteractionEnabled = true
        
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
