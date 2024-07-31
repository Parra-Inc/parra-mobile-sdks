//
//  ParraCardModal.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import UIKit

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
