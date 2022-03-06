//
//  ViewController.swift
//  Parra Feedback SDK Demo
//
//  Created by Michael MacCallum on 11/22/21.
//

import UIKit
import ParraFeedback

class ViewController: UIViewController {
    private let activityIndicator = UIActivityIndicatorView(frame: .zero)
    private let feedbackView = ParraFeedbackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicator.style = .large
        activityIndicator.tintColor = .black
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        view.addConstraint(activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        view.addConstraint(activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor))

                        
        print("Fetching Parra Cards...")
        ParraFeedback.fetchFeedbackCards { cards, error in
            if let error = error {
                print("Error fetching Parra cards: \(error)")
                return
            }
            
            self.activityIndicator.removeFromSuperview()

            if cards.isEmpty {
                print("No Parra cards currently available.")
            } else {
                self.view.addSubview(self.feedbackView)
                self.view.addConstraint(self.feedbackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 200))
            }
        }
    }
}

