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
    public var cardItems: [CardItem] {
        didSet {
            cardItemsDidChange()
        }
    }
    
    private var currentCardInfo: CurrentCardInfo?

    private var constraintsOnSuperView = [NSLayoutConstraint]()
    private var constraintsOncontainerView = [NSLayoutConstraint]()

    private let containerView = UIView(frame: .zero)
    private let contentView = UIView(frame: .zero)
    private let backButton = UIButton.systemButton(
        with: UIImage(named: "ArrowLeft")!,
        target: self,
        action: #selector(backButtonPressed(button:))
    )
    private let forwardButton = UIButton.systemButton(
        with: UIImage(named: "ArrowRight")!,
        target: self,
        action: #selector(forwardButtonPressed(button:))
    )
    private let poweredByLabel = UILabel(frame: .zero)
    private lazy var navigationStack: UIStackView = ({
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
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        layer.masksToBounds = false
        
        addSubview(containerView)
        containerView.addSubview(navigationStack)
        addSubview(contentView)
                
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.masksToBounds = true

        configureContentView()
        configureNavigationStack()
        
        applyConfig(config)
        
        transitionToNextCard(animated: false)
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        removeConstraints(constraintsOnSuperView)
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard let superview = superview else {
            return
        }
        
        constraintsOnSuperView = [
            leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor)
        ]

        NSLayoutConstraint.activate(constraintsOnSuperView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func cardItemsDidChange() {
        transitionToNextCard()
    }
    
    private func transitionToNextCard(animated: Bool = false) {
        if let currentCardInfo = currentCardInfo {
            if let currentIndex = cardItems.firstIndex(where: { $0 == currentCardInfo.cardItem }) {
                
                if currentIndex == cardItems.count - 1 {
                    transitionToCardItem(nil, animated: animated)
                } else {
                    transitionToCardItem(cardItems[currentIndex + 1], animated: animated)
                }
            } else {
                transitionToCardItem(cardItems.first, animated: animated)
            }
        } else {
            transitionToCardItem(cardItems.first, animated: animated)
        }
    }
        
    private func transitionToCardItem(_ cardItem: CardItem?, animated: Bool = false) {
        let nextCard = cardViewFromCardItem(cardItem)
                        
        contentView.addSubview(nextCard)

        NSLayoutConstraint.activate([
            nextCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nextCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nextCard.topAnchor.constraint(equalTo: contentView.topAnchor),
            nextCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
        let applyNextView = {
            if let currentCardInfo = self.currentCardInfo {
                NSLayoutConstraint.deactivate(currentCardInfo.cardView.constraints)
                currentCardInfo.cardView.removeFromSuperview()
                self.currentCardInfo = nil
            }
            
            self.currentCardInfo = CurrentCardInfo(
                cardView: nextCard,
                cardItem: cardItem
            )
        }
                
        if animated {
            self.currentCardInfo?.cardView.transform = .identity
            nextCard.transform = .identity.translatedBy(x: self.frame.width, y: 0.0)

            contentView.invalidateIntrinsicContentSize()
            
            UIView.animate(
                withDuration: 0.375,
                delay: 0.0,
                options: [.curveEaseInOut, .beginFromCurrentState]) {
                    self.currentCardInfo?.cardView.transform = .identity.translatedBy(x: -self.frame.width, y: 0.0)
                    nextCard.transform = .identity
                } completion: { _ in
                    applyNextView()
                }
        } else {
            applyNextView()
        }
    }
    
    private func cardViewFromCardItem(_ cardItem: CardItem?) -> ParraCardView {
        guard let cardItem = cardItem else {
            return ParraActionCardView(
                title: "You're all caught up for now!",
                subtitle: "a subtitle",
                actionTitle: "Have other feedback?"
            ) {
                print("tapped cta")
            }
        }
        
        switch (cardItem.data) {
        case .question(let question):
            return ParraQuestionCardView(question: question)
        }
    }
    
    private func applyConfig(_ config: ParraFeedbackViewConfig) {
        
        containerView.removeConstraints(constraintsOncontainerView)
        constraintsOncontainerView = [
            containerView.topAnchor.constraint(
                equalTo: topAnchor, constant: config.contentInsets.top
            ),
            containerView.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: config.contentInsets.left
            ),
            containerView.bottomAnchor.constraint(
                equalTo: bottomAnchor, constant: -config.contentInsets.bottom
            ),
            containerView.trailingAnchor.constraint(
                equalTo: trailingAnchor, constant: -config.contentInsets.right
            )
        ]
        NSLayoutConstraint.activate(constraintsOncontainerView)
        
        containerView.backgroundColor = config.backgroundColor
        containerView.layer.cornerRadius = config.cornerRadius
        
        backButton.tintColor = config.tintColor
        forwardButton.tintColor = config.tintColor
                
        layer.shadowColor = config.shadowColor.cgColor
        layer.shadowOpacity = Float(config.shadowOpacity)
        layer.shadowRadius = config.shadowRadius
        layer.shadowOffset = config.shadowSize
        layer.bounds = bounds
        layer.position = center
    }
    
    private func configureContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.setContentCompressionResistancePriority(.required, for: .vertical)
        contentView.clipsToBounds = true
                
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: navigationStack.bottomAnchor, constant: 10),
            contentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
            contentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0),
            contentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 170)
        ])
    }
    
    private func configureNavigationStack() {
        navigationStack.translatesAutoresizingMaskIntoConstraints = false
        navigationStack.alignment = .center
        navigationStack.axis = .horizontal
        navigationStack.distribution = .equalSpacing
         
        poweredByLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
        poweredByLabel.textColor = UIColor(hue: 0.0, saturation: 0.0, brightness: 0.0, alpha: 0.1)
        poweredByLabel.textAlignment = .center
        
        let defaultAttributes = [NSAttributedString.Key.kern: 0.24]
        let poweredBy = NSMutableAttributedString(string: "Powered by ", attributes: defaultAttributes)

        let pacifico = UIFont(name: "Pacifico-Regular", size: 16)!
        let parra = NSMutableAttributedString(string: "Parra", attributes: [.font: pacifico])
        parra.addAttributes(defaultAttributes, range: NSMakeRange(0, parra.length))
        poweredBy.append(parra)

        poweredByLabel.attributedText = poweredBy
        
        NSLayoutConstraint.activate([
            navigationStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            navigationStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            navigationStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
        ])
    }
    
    @objc private func backButtonPressed(button: UIButton) {
        
    }
    
    @objc private func forwardButtonPressed(button: UIButton) {
        transitionToNextCard(animated: true)
    }
}
