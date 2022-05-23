//
//  ParraFeedbackInView.swift
//  Parra Feedback SDK Demo
//
//  Created by Mick MacCallum on 3/6/22.
//

import UIKit
import ParraFeedback

class ParraFeedbackInView: UIViewController {
    private let activityIndicator = UIActivityIndicatorView(frame: .zero)
    private let feedbackView = ParraFeedbackView(config: .default)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.style = .large
        activityIndicator.tintColor = .black
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        view.addConstraint(activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        view.addConstraint(activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor))

        print("Fetching Parra Cards...")
        ParraFeedback.fetchFeedbackCards { cards, error in
            self.activityIndicator.removeFromSuperview()

            if error != nil || cards.isEmpty {
                let text = error != nil ? "Error fetching Parra cards: \(error!)" : "No Parra cards currently available."
                
                let label = UILabel(frame: .zero)
                label.text = text
                label.numberOfLines = 0
                label.translatesAutoresizingMaskIntoConstraints = false
                
                self.view.addSubview(label)
                self.view.addConstraints([
                    label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                    label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                    label.widthAnchor.constraint(lessThanOrEqualTo: self.view.widthAnchor, constant: -24)
                ])
                
                return
            }

            self.view.addSubview(self.feedbackView)
            
            NSLayoutConstraint.activate([
                self.feedbackView.centerYAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerYAnchor),
                self.feedbackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.feedbackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            ])
        }
    }
}
