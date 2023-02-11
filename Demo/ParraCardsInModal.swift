//
//  ParraCardsInModal.swift
//  Demo
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import UIKit
import ParraFeedback
import ParraCore

class ParraCardsInModal: UIViewController {
    @IBOutlet weak var popupButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var drawerButton: UIButton!

    private var cards: [ParraCardItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        popupButton.isEnabled = false
        drawerButton.isEnabled = false

        ParraFeedback.fetchFeedbackCards { [self] response in
            switch response {
            case .success(let cards):
                self.cards = cards

                popupButton.isEnabled = true
                drawerButton.isEnabled = true
            case .failure(let error):
                errorLabel.text = error.localizedDescription
            }
        }
    }

    @IBAction func presentPopupStyleFeedbackModal(_ sender: UIButton) {
        ParraFeedback.presentCardPopup(with: cards, fromViewController: self)
    }

    @IBAction func presentDrawerStyleFeedbackModal(_ sender: UIButton) {
        ParraFeedback.presentCardDrawer(with: cards, fromViewController: self)
    }
}
