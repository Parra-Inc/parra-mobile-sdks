//
//  ParraCardModal.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import UIKit
import ParraCore

// raw values used in events
public enum ParraCardModalType: String {
    case popup
    case drawer

    // To avoid these values changing unintentionally.
    var eventName: String {
        switch self {
        case .popup:
            return "popup"
        case .drawer:
            return "drawer"
        }
    }
}

public enum ParraCardModalTransitionStyle {
    case none
    case fade
    case slide
}

internal protocol ParraModal {}

internal protocol ParraCardModal: ParraModal {
    init(cards: [ParraCardItem],
         config: ParraCardViewConfig,
         transitionStyle: ParraCardModalTransitionStyle)
}

internal class ParraCardModalViewController: UIViewController {
    internal let cardView: ParraCardView
    internal let modalType: ParraCardModalType
    internal let transitionStyle: ParraCardModalTransitionStyle

    init(cards: [ParraCore.ParraCardItem],
                  config: ParraCardViewConfig,
                  transitionStyle: ParraCardModalTransitionStyle,
                  modalType: ParraCardModalType) {

        self.transitionStyle = transitionStyle
        self.modalType = modalType

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
}

extension ParraCardModalViewController: ParraCardViewDelegate {
    func parraCardViewDidRequestDismissal(_ parraCardView: ParraCardView) {
        dismissModal()
    }
}
