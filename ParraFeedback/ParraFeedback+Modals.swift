//
//  ParraFeedback+Modals.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit
import ParraCore

public extension ParraFeedback {
    static func presentCardPopup(with cards: [ParraCardItem],
                                 fromViewController viewController: UIViewController?,
                                 config: ParraCardViewConfig = .default) {

        parraLogW("ParraFeedback.presentCardPopup ")

        guard let vc = viewController ?? UIViewController.topMostViewController() else {
            parraLogW("ParraFeedback.presentCardPopup ")
            return
        }

//        guard let viewController = UIViewController.topMostViewController()
    }
}
