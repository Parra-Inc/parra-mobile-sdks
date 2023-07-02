//
//  ParraCardsInView.swift
//  Parra Feedback SDK Demo
//
//  Created by Mick MacCallum on 3/6/22.
//

import UIKit
import Parra

class ParraCardsInView: UIViewController {
    private let activityIndicator = UIActivityIndicatorView(frame: .zero)
    private let cardView = ParraCardView(config: .default)

    override func viewDidLoad() {
        super.viewDidLoad()

        cardView.delegate = self

        activityIndicator.style = .large
        activityIndicator.tintColor = .black
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        view.addConstraint(activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        view.addConstraint(activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor))

        print("Fetching Parra Cards...")
        ParraFeedback.shared.fetchFeedbackCards { [self] cards, error in
            activityIndicator.removeFromSuperview()

            if error != nil || cards.isEmpty {
                let text = error != nil ? "Error fetching Parra cards: \(error!)" : "No Parra cards currently available."
                
                let label = UILabel(frame: .zero)
                label.text = text
                label.numberOfLines = 0
                label.translatesAutoresizingMaskIntoConstraints = false
                
                view.addSubview(label)
                view.addConstraints([
                    label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                    label.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -24)
                ])
                
                return
            }

            view.addSubview(cardView)

            NSLayoutConstraint.activate([
                cardView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                cardView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                cardView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            ])
        }
    }
}

extension ParraCardsInView: ParraCardViewDelegate {
    func parraCardViewDidRequestDismissal(_ parraCardView: ParraCardView) {
        cardView.removeFromSuperview()
    }
}
