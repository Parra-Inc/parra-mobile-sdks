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

internal class ParraCardDrawerViewController: UIViewController, ParraCardModal {
    private let cardView: ParraCardView
    private let transitionStyle: ParraCardModalTransitionStyle

    required init(cards: [ParraCardItem],
                  config: ParraCardViewConfig,
                  transitionStyle: ParraCardModalTransitionStyle) {

        self.transitionStyle = transitionStyle

        cardView = ParraCardView(config: config)

        super.init(nibName: nil, bundle: nil)

        cardView.cardItems = cards
        cardView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(cardView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }

    @objc private func dismissPopup() {
        dismiss(animated: true)
    }
}

extension ParraCardDrawerViewController: ParraCardViewDelegate {
    func parraCardViewDidRequestDismissal(_ parraCardView: ParraCardView) {
        dismissPopup()
    }
}
