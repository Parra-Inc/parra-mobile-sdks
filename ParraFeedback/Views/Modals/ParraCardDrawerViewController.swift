//
//  ParraCardDrawerViewController.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit
import ParraCore

internal class ParraCardDrawerViewController: ParraCardModalViewController, ParraCardModal {
    required init(
        cards: [ParraCore.ParraCardItem],
        config: ParraCardViewConfig,
        transitionStyle: ParraCardModalTransitionStyle
    ) {
        super.init(
            cards: cards,
            config: config,
            transitionStyle: transitionStyle,
            modalType: .drawer
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = cardView.config.backgroundColor
        view.addSubview(cardView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}
