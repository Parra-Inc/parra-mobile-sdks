//
//  Direction.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation
import UIKit

enum Direction {
    case left
    case right

    // MARK: - Internal

    var swipeDirection: UISwipeGestureRecognizer.Direction {
        switch self {
        case .left:
            return .left
        case .right:
            return .right
        }
    }
}
