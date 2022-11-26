//
//  ParraCardsInModal.swift
//  Demo
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import UIKit
import ParraFeedback

class ParraCardsInModal: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func presentPopupStyleFeedbackModal(_ sender: UIButton) {

        ParraFeedback.fetchFeedbackCards(appArea: .all) { [self] response in
            switch response {
            case .success(let cards):
                ParraFeedback.presentCardPopup(with: cards, fromViewController: self)
            case .failure(let error):
                print(error)
            }
        }
    }

    @IBAction func presentDrawerStyleFeedbackModal(_ sender: UIButton) {
    }
}
