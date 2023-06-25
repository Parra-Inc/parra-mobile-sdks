//
//  ParraCardModalViewController.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 6/18/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit

internal class ParraCardModalViewController: UIViewController {
    internal let cardView: ParraCardView
    internal let modalType: ParraCardModalType
    internal let transitionStyle: ParraCardModalTransitionStyle

    private var onDismiss: (() -> Void)?

    init(
        cards: [ParraCardItem],
        config: ParraCardViewConfig,
        transitionStyle: ParraCardModalTransitionStyle,
        modalType: ParraCardModalType,
        onDismiss: (() -> Void)? = nil
    ) {
        self.transitionStyle = transitionStyle
        self.modalType = modalType
        self.onDismiss = onDismiss

        // We count on the fact that we control when these modals are presented to know that
        // if one is instantiated, presentation is inevitable. This allows us to guarentee that
        // the impression event for the modal is submitted before the card view starts laying out cards.
        Parra.logAnalyticsEvent(ParraSessionEventType.impression(
            location: "modal:\(modalType.eventName)",
            module: ParraFeedback.self
        ), params: [
            "type": modalType.rawValue
        ])

        cardView = ParraCardView(config: config)

        super.init(nibName: nil, bundle: nil)

        cardView.cardItems = cards
        cardView.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func dismissModal() {
        dismiss(animated: true)
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
    }

    override func endAppearanceTransition() {
        super.endAppearanceTransition()

        if isBeingDismissed {
            onDismiss?()
        }
    }
}

extension ParraCardModalViewController: ParraCardViewDelegate {
    func parraCardViewDidRequestDismissal(_ parraCardView: ParraCardView) {
        dismissModal()
    }
}
