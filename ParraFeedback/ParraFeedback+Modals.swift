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
    // MARK: - Modals

    static func presentCardPopup(
        with cards: [ParraCardItem],
        fromViewController: UIViewController?,
        config: ParraCardViewConfig = .default,
        transitionStyle: ParraCardModalTransitionStyle = .slide,
        userDismissable: Bool = true,
        onDismiss: (() -> Void)? = nil
    ) {
        parraLogInfo("Presenting card popup view controller with \(cards.count) card(s)")

        let cardViewController = ParraCardPopupViewController(
            cards: cards,
            config: config,
            transitionStyle: transitionStyle,
            userDismissable: userDismissable,
            onDismiss: onDismiss
        )

        presentModal(
            modal: cardViewController,
            fromViewController: fromViewController,
            transitionStyle: transitionStyle,
            config: config
        )
    }

    @available(iOS 15.0, *)
    static func presentCardDrawer(
        with cards: [ParraCardItem],
        fromViewController: UIViewController?,
        config: ParraCardViewConfig = .drawerDefault,
        onDismiss: (() -> Void)? = nil
    ) {
        parraLogInfo("Presenting drawer view controller with \(cards.count) card(s)")

        let transitionStyle = ParraCardModalTransitionStyle.slide
        let cardViewController = ParraCardDrawerViewController(
            cards: cards,
            config: config,
            transitionStyle: transitionStyle,
            onDismiss: onDismiss
        )

        if let sheetPresentationController = cardViewController.sheetPresentationController {
            sheetPresentationController.detents = [.medium()]
            sheetPresentationController.prefersGrabberVisible = true
        }

        presentModal(
            modal: cardViewController,
            fromViewController: fromViewController,
            transitionStyle: transitionStyle,
            config: config
        )
    }

    // MARK: - Feedback Forms

    static func presentFeedbackForm(with form: ParraFeedbackFormResponse,
                                    config: ParraCardViewConfig = .drawerDefault) {

        let formViewController = ParraFeedbackFormViewController(
            form: form,
            config: config
        )

        if #available(iOS 15.0, *) {
            if let sheetPresentationController = formViewController.sheetPresentationController {
                sheetPresentationController.detents = [.large()]
                sheetPresentationController.prefersGrabberVisible = true
            }
        }

        presentModal(
            modal: formViewController,
            fromViewController: nil,
            transitionStyle: .slide,
            config: config
        )
    }

    // MARK: - Helpers
    private static func presentModal(modal: UIViewController & ParraModal,
                                     fromViewController: UIViewController?,
                                     transitionStyle: ParraCardModalTransitionStyle,
                                     config: ParraCardViewConfig) {
        guard let vc = fromViewController ?? UIViewController.topMostViewController() else {
            parraLogWarn("Missing view controller to present popup from.")
            return
        }

        vc.present(modal, animated: transitionStyle != .none)
    }
}
