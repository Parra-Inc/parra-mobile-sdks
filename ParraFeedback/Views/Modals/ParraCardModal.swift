//
//  ParraCardModal.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation
import ParraCore

public enum ParraCardModalTransitionStyle {
    case none
    case fade
    case slide
}

internal protocol ParraCardModal  {
    var transitionStyle: ParraCardModalTransitionStyle { get }

    init(cards: [ParraCardItem],
         config: ParraCardViewConfig,
         transitionStyle: ParraCardModalTransitionStyle)
}
