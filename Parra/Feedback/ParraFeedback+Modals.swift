//
//  ParraFeedback+Modals.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit

private let logger = Logger(category: "Modals")

public extension ParraFeedback {
    // MARK: - Modals

    static func presentCardPopup(
        with cards: [ParraCardItem],
        from fromViewController: UIViewController? = nil,
        config: ParraCardViewConfig = .default,
        transitionStyle: ParraCardModalTransitionStyle = .slide,
        userDismissable: Bool = true,
        onDismiss: (() -> Void)? = nil
    ) {
        shared.presentCardPopup(
            with: cards,
            from: fromViewController,
            config: config,
            transitionStyle: transitionStyle,
            userDismissable: userDismissable,
            onDismiss: onDismiss
        )
    }

    internal func presentCardPopup(
        with cards: [ParraCardItem],
        from fromViewController: UIViewController? = nil,
        config: ParraCardViewConfig = .default,
        transitionStyle: ParraCardModalTransitionStyle = .slide,
        userDismissable: Bool = true,
        onDismiss: (() -> Void)? = nil
    ) {
        logger
            .info(
                "Presenting card popup view controller with \(cards.count) card(s)"
            )

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
            transitionStyle: transitionStyle
        )
    }

    static func presentCardDrawer(
        with cards: [ParraCardItem],
        from fromViewController: UIViewController? = nil,
        config: ParraCardViewConfig = .drawerDefault,
        onDismiss: (() -> Void)? = nil
    ) {
        shared.presentCardDrawer(
            with: cards,
            from: fromViewController,
            config: config,
            onDismiss: onDismiss
        )
    }

    internal func presentCardDrawer(
        with cards: [ParraCardItem],
        from fromViewController: UIViewController? = nil,
        config: ParraCardViewConfig = .drawerDefault,
        onDismiss: (() -> Void)? = nil
    ) {
        logger
            .info(
                "Presenting drawer view controller with \(cards.count) card(s)"
            )

        let transitionStyle = ParraCardModalTransitionStyle.slide
        let cardViewController = ParraCardDrawerViewController(
            cards: cards,
            config: config,
            transitionStyle: transitionStyle,
            onDismiss: onDismiss
        )

        if let sheetPresentationController = cardViewController
            .sheetPresentationController
        {
            sheetPresentationController.detents = [.medium()]
            sheetPresentationController.prefersGrabberVisible = true
        }

        presentModal(
            modal: cardViewController,
            fromViewController: fromViewController,
            transitionStyle: transitionStyle
        )
    }

    // MARK: - Helpers

    private func presentModal(
        modal: UIViewController & ParraModal,
        fromViewController: UIViewController?,
        transitionStyle: ParraCardModalTransitionStyle
    ) {
        guard let vc = fromViewController ?? UIViewController
            .topMostViewController() else
        {
            logger.warn("Missing view controller to present popup from.")
            return
        }

        vc.present(modal, animated: transitionStyle != .none)
    }
}
