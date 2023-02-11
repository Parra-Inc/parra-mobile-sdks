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
}

public enum ParraCardModalTransitionStyle {
    case none
    case fade
    case slide
}

internal protocol ParraCardModal  {
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

        cardView = ParraCardView(config: config)

        super.init(nibName: nil, bundle: nil)

        cardView.cardItems = cards
        cardView.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Parra.logAnalyticsEvent(ParraSessionEventType.impression(
            location: "modal",
            module: ParraFeedback.self
        ), params: [
            "type": modalType.rawValue
        ])
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
