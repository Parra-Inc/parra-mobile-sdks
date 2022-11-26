//
//  ParraFeedback+Modals.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit
import ParraCore

public extension ParraFeedback {
    static func presentCardPopup(with cards: [ParraCardItem],
                                 fromViewController viewController: UIViewController?,
                                 config: ParraCardViewConfig = .default,
                                 transitionStyle: ParraCardModalTransitionStyle = .slide) {

        guard let vc = viewController ?? UIViewController.topMostViewController() else {
            parraLogW("Missing view controller to present popup from.")
            return
        }

        parraLogV("Presenting card popup view controller with \(cards.count) card(s)")

        let cardViewController = ParraCardPopupViewController(
            cards: cards,
            config: config,
            transitionStyle: transitionStyle
        )

        vc.present(cardViewController, animated: transitionStyle != .none)
    }
}
