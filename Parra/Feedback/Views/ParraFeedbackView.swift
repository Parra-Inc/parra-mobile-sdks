//
//  ParraFeedbackView.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 11/23/21.
//

import UIKit

public struct ParraFeedbackViewConfig {
    var backgroundColor: UIColor
    var tintColor: UIColor
    var cornerRadius: CGFloat
    var contentInsets: UIEdgeInsets
    var shadowColor: UIColor
    var shadowOpacity: CGFloat
    var shadowRadius: CGFloat
    var shadowSize: CGSize
}

enum Direction {
    case left, right
}

struct VisibleButtonOptions: OptionSet {
    static let back = VisibleButtonOptions(rawValue: 1)
    static let forward = VisibleButtonOptions(rawValue: 1 << 1)
    
    let rawValue: Int8
}

struct CurrentCardInfo {
    let cardView: ParraCardView
    let cardItem: CardItem?
}

public let ParraFeedbackViewDefaultConfig = ParraFeedbackViewConfig(
    backgroundColor: UIColor(hex: 0xFAFAFA),
    tintColor: UIColor(hex: 0x200E32),
    cornerRadius: 12,
    contentInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
    shadowColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.1),
    shadowOpacity: 1.0,
    shadowRadius: 2.0,
    shadowSize: .init(width: 0.0, height: 2.0)
)

public class ParraFeedbackView: UIView {
    let questionHandler = ParraQuestionHandler()
    
    var cardItems: [CardItem] {
        didSet {
            let existedPreviously = !oldValue.isEmpty
            
            transitionToNextCard(direction: .right, animated: existedPreviously)
        }
    }
    
    var currentCardInfo: CurrentCardInfo?

    var constraintsOnSuperView = [NSLayoutConstraint]()
    var constraintsOncontainerView = [NSLayoutConstraint]()

    let containerView = UIView(frame: .zero)
    let contentView = UIView(frame: .zero)
    let backButton = UIButton.systemButton(
        with: UIImage.parraImageNamed("ArrowLeft")!,
        target: self,
        action: #selector(navigateToPreviousCard)
    )
    let forwardButton = UIButton.systemButton(
        with: UIImage.parraImageNamed("ArrowRight")!,
        target: self,
        action: #selector(navigateToNextCard)
    )
    let poweredByLabel = UILabel(frame: .zero)
    lazy var navigationStack: UIStackView = ({
        return UIStackView(arrangedSubviews: [
            backButton, poweredByLabel, forwardButton
        ])
    })()

    public required init(
        cardItems: [CardItem] = [],
        config: ParraFeedbackViewConfig = ParraFeedbackViewDefaultConfig
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
            
            ParraFeedback.triggerSync()
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(didReceiveCardChangeNotification(notification:)),
                                                   name: ParraFeedback.cardsDidChangeNotification,
                                                   object: nil)
            
            cardItems = ParraFeedback.shared.dataManager.currentCards()
        }
    }
    
    @objc private func didReceiveCardChangeNotification(notification: Notification) {
        cardItems = ParraFeedback.shared.dataManager.currentCards()
    }
}
