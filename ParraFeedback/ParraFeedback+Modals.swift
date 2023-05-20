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

        parraLogInfo("Presenting card popup view controller with \(cards.count) card(s)")

        let cardViewController = ParraCardPopupViewController(
            cards: cards,
            config: config,
            transitionStyle: transitionStyle
        )

        presentModal(
            modal: cardViewController,
            fromViewController: fromViewController,
            config: config
        )
    }

    @available(iOS 15.0, *)
    static func presentCardDrawer(with cards: [ParraCardItem],
                                  fromViewController: UIViewController?,
                                  config: ParraCardViewConfig = .drawerDefault) {

        parraLogInfo("Presenting drawer view controller with \(cards.count) card(s)")

        let cardViewController = ParraCardDrawerViewController(
            cards: cards,
            config: config,
            transitionStyle: .slide
        )

        if let sheetPresentationController = cardViewController.sheetPresentationController {
            sheetPresentationController.detents = [.medium()]
            sheetPresentationController.prefersGrabberVisible = true
        }

        presentModal(
            modal: cardViewController,
            fromViewController: fromViewController,
            config: config
        )
    }

    private static func presentModal(modal: ParraCardModalViewController & ParraCardModal,
                                     fromViewController: UIViewController?,
                                     config: ParraCardViewConfig) {
        guard let vc = fromViewController ?? UIViewController.topMostViewController() else {
            parraLogWarn("Missing view controller to present popup from.")
            return
        }

        vc.present(modal, animated: modal.transitionStyle != .none)
    }
}
