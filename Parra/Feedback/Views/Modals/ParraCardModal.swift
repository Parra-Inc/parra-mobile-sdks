//
//  ParraCardModal.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import UIKit

struct ParraCardModalViewedEvent: ParraDataEvent {
    // MARK: Lifecycle

    init(modalType: ParraCardModalType) {
        self.name = modalType.eventName
        self.extra = [
            "type": modalType.rawValue
        ]
    }

    // MARK: Internal

    var name: String
    var extra: [String: Any]
}

// raw values used in events
enum ParraCardModalType: String {
    case popup
    case drawer

    // MARK: Internal

    // To avoid these values changing unintentionally.
    var eventName: String {
        switch self {
        case .popup:
            return "view:popup"
        case .drawer:
            return "view:drawer"
        }
    }

    var event: ParraDataEvent {
        return ParraCardModalViewedEvent(modalType: self)
    }
}

public enum ParraCardModalTransitionStyle {
    case none
    case fade
    case slide
}

protocol ParraModal {}

protocol ParraCardModal: ParraModal {
    init(
        cards: [ParraCardItem],
        config: ParraCardViewConfig,
        transitionStyle: ParraCardModalTransitionStyle,
        onDismiss: (() -> Void)?
    )
}
