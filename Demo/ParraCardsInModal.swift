//
//  ParraCardsInModal.swift
//  Demo
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import UIKit
import Parra

fileprivate let logger = Logger(category: "ParraCardsInModal", extra: ["top-level": "extra-thing"])

class ParraCardsInModal: UIViewController {
    @IBOutlet weak var popupButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var drawerButton: UIButton!

    private var cards: [ParraCardItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        popupButton.isEnabled = false
        drawerButton.isEnabled = false

        logger.info("finished disabling buttons", [
            "popupButtonEnabled": popupButton.isEnabled,
            "drawerButtonEnabled": drawerButton.isEnabled
        ])

        logger.info("fetching feedback cards")

        ParraFeedback.shared.fetchFeedbackCards { [self] response in
            // TODO: If a name isn't provided here, could we capture and name a closure
            // to use as the name?
            logger.withScope(
                named: "fetch cards completion",
                ["response": String(describing: response)]
            ) { logger in
                switch response {
                case .success(let cards):
                    logger.debug("success")
                    self.cards = cards

                    popupButton.isEnabled = true
                    drawerButton.isEnabled = true
                    logger.debug("finished enabling buttons", [
                        "popupButtonEnabled": popupButton.isEnabled,
                        "drawerButtonEnabled": drawerButton.isEnabled
                    ])
                case .failure(let error):
                    errorLabel.text = error.localizedDescription
                    logger.error("failed to fetch cards", error)
                }
            }
        }
    }

    @IBAction func presentPopupStyleFeedbackModal(_ sender: UIButton) {
        logger.withScope { logger in
            logger.info("present popup style")

            ParraFeedback.shared.presentCardPopup(with: cards, from: self) {
                logger.info("dismissing popup style", ["super-nested-extra": true])
            }
        }
    }

    @IBAction func presentDrawerStyleFeedbackModal(_ sender: UIButton) {
        logger.error(
            "Error presenting drawer feedback modal",
            ParraError.message("Not really, it's a fake error"),
            ["key": "value-idk-something-broken"]
        )
        
        ParraFeedback.shared.presentCardDrawer(with: cards, from: self)
    }
}
