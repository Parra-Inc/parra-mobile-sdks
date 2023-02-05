//
//  ParraCardPopupViewController.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import UIKit
import ParraCore

internal class ParraCardPopupViewController: ParraCardModalViewController, ParraCardModal {

    required init(cards: [ParraCardItem],
                  config: ParraCardViewConfig,
                  transitionStyle: ParraCardModalTransitionStyle) {

        super.init(
            cards: cards,
            config: config,
            transitionStyle: transitionStyle,
            modalType: .popup
        )

        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let dismissButton = UIButton.systemButton(
            with: UIImage(systemName: "xmark")!,
            target: self,
            action: #selector(dismissModal)
        )

        dismissButton.tintColor = cardView.config.tintColor
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dismissButton)
        view.backgroundColor = .black.withAlphaComponent(0.3)
        view.addSubview(cardView)

        NSLayoutConstraint.activate([
            cardView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            cardView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            dismissButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,  constant: -24)
        ])

        let backgroundTap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissModal)
        )

        backgroundTap.delegate = self

        view.addGestureRecognizer(backgroundTap)

        if transitionStyle == .slide {
            let backgroundSwipe = UISwipeGestureRecognizer(
                target: self,
                action: #selector(dismissModal)
            )

            backgroundSwipe.direction = .down

            view.addGestureRecognizer(backgroundSwipe)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if transitionStyle == .slide {
            cardView.transform = cardViewDismissedTransform()

            transitionCoordinator?.animate { [self] context in
                cardView.transform = .identity
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if transitionStyle == .slide {
            cardView.transform = .identity

            transitionCoordinator?.animate { [self] context in
                cardView.transform = cardViewDismissedTransform()
            }
        }
    }

    private func cardViewDismissedTransform() -> CGAffineTransform {
        return .identity.translatedBy(
            x: 0.0,
            y: view.bounds.height / 2 + cardView.bounds.height / 2
        )
    }
}

extension ParraCardPopupViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        guard let view = touch.view else {
            return false
        }

        return !view.isDescendant(of: cardView)
    }
}