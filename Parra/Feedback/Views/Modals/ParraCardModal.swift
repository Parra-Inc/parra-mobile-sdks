//
//  ParraCardModal.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import UIKit

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
    init(
        cards: [ParraCardItem],
        config: ParraCardViewConfig,
        transitionStyle: ParraCardModalTransitionStyle,
        onDismiss: (() -> Void)?
    )
}
