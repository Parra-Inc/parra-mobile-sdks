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
                                 fromViewController: UIViewController?,
                                 config: ParraCardViewConfig = .default,
                                 transitionStyle: ParraCardModalTransitionStyle = .slide) {

        parraLogV("Presenting card popup view controller with \(cards.count) card(s)")

        let cardViewController = ParraCardPopupViewController(
            cards: cards,
            config: config,
            transitionStyle: transitionStyle
        )

        presentModal(
            modal: cardViewController,
            fromViewController: fromViewController,
            config: config,
            transitionStyle: transitionStyle
        )
    }

    @available(iOS 15.0, *)
    static func presentCardDrawer(with cards: [ParraCardItem],
                                  fromViewController: UIViewController?,
                                  config: ParraCardViewConfig = .default,
                                  transitionStyle: ParraCardModalTransitionStyle = .slide) {

        parraLogV("Presenting drawer view controller with \(cards.count) card(s)")

        let cardViewController = ParraCardDrawerViewController(
            cards: cards,
            config: config,
            transitionStyle: transitionStyle
        )

        if let sheetPresentationController = cardViewController.sheetPresentationController {
            sheetPresentationController.detents = [.medium()]
            sheetPresentationController.prefersGrabberVisible = true
        }

        presentModal(
            modal: cardViewController,
            fromViewController: fromViewController,
            config: config,
            transitionStyle: transitionStyle
        )
    }

    private static func presentModal(modal: UIViewController & ParraCardModal,
                                     fromViewController: UIViewController?,
                                     config: ParraCardViewConfig,
                                     transitionStyle: ParraCardModalTransitionStyle) {
        guard let vc = fromViewController ?? UIViewController.topMostViewController() else {
            parraLogW("Missing view controller to present popup from.")
            return
        }

        vc.present(modal, animated: transitionStyle != .none)
    }
}
