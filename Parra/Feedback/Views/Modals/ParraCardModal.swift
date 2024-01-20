//
//  ParraCardModal.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import UIKit

internal struct ParraCardModalViewedEvent: ParraDataEvent {
    var name: String
    var extra: [String : Any]

    init(modalType: ParraCardModalType) {
        self.name = modalType.eventName
        self.extra = [
            "type": modalType.rawValue
        ]
    }
}

// raw values used in events
internal enum ParraCardModalType: String {
    case popup
    case drawer

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

internal protocol ParraModal {}

internal protocol ParraCardModal: ParraModal {
    init(
        cards: [ParraCardItem],
        config: ParraCardViewConfig,
        transitionStyle: ParraCardModalTransitionStyle,
        onDismiss: (() -> Void)?
    )
}
