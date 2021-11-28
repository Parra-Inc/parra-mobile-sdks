//
//  ViewController.swift
//  Parra Feedback SDK Demo
//
//  Created by Michael MacCallum on 11/22/21.
//

import UIKit
import ParraFeedback

class ViewController: UIViewController {
    private let feedbackView = ParraFeedbackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(feedbackView)
                
        Task {
            print("fetching...")
            let response = try await ParraFeedback.fetchFeedbackCards()
        
            view.addConstraint(feedbackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100))

            feedbackView.cardItems = response.cards
            
            print(response.cards)
        }
    }
}

