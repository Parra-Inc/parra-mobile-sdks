//
//  ParraFeedbackView.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 11/23/21.
//

import UIKit
import ParraCore


public class ParraFeedbackView: UIView {
    let questionHandler = ParraQuestionHandler()
    
    var cardItems: [CardItem] {
        didSet {
            let existedPreviously = !oldValue.isEmpty
            
            if cardItems != oldValue {
                transitionToNextCard(direction: .right, animated: existedPreviously)
            }
        }
    }
    
    var currentCardInfo: CurrentCardInfo?

    var constraintsOnSuperView = [NSLayoutConstraint]()
    var constraintsOncontainerView = [NSLayoutConstraint]()

    let containerView = UIView(frame: .zero)
    let contentView = UIView(frame: .zero)
    lazy var backButton: UIButton = {
        return UIButton.systemButton(
            with: UIImage.parraImageNamed("ArrowLeft")!,
            target: self,
            action: #selector(navigateToPreviousCard)
        )
    }()
    lazy var forwardButton: UIButton = {
        return UIButton.systemButton(
            with: UIImage.parraImageNamed("ArrowRight")!,
            target: self,
            action: #selector(navigateToNextCard)
        )
    }()
    let poweredByLabel = UILabel(frame: .zero)
    lazy var navigationStack: UIStackView = ({
        return UIStackView(arrangedSubviews: [
            backButton, poweredByLabel, forwardButton
        ])
    })()

    public required init(
        cardItems: [CardItem] = [],
        config: ParraFeedbackViewConfig = .default
    ) {
        self.cardItems = cardItems
        
        super.init(frame: .zero)
        
        questionHandler.questionHandlerDelegate = self
        
        configureSubviews(config: config)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)

        if newWindow == nil {
            NotificationCenter.default.removeObserver(self, name: ParraFeedback.cardsDidChangeNotification,
                                                      object: nil)
            
            Parra.triggerSync()
        } else {
            checkAndUpdateCards()
        }
    }
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveCardChangeNotification(notification:)),
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
