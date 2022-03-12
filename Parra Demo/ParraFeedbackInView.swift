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
    private let feedbackView = ParraFeedbackView()

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

            if let error = error {
                print("Error fetching Parra cards: \(error)")
                return
            }
            
            if cards.isEmpty {
                print("No Parra cards currently available.")
            } else {
                self.view.addSubview(self.feedbackView)
                self.view.addConstraint(self.feedbackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 200))
            }
        }
    }
}
