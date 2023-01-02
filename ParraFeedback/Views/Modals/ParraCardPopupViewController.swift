//
//  ParraCardPopupViewController.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import UIKit
import ParraCore

internal class ParraCardPopupViewController: UIViewController, ParraCardModal {
    private let cardView: ParraCardView
    internal let transitionStyle: ParraCardModalTransitionStyle

    required init(cards: [ParraCardItem],
                  config: ParraCardViewConfig,
                  transitionStyle: ParraCardModalTransitionStyle) {

        self.transitionStyle = transitionStyle

        cardView = ParraCardView(config: config)

        super.init(nibName: nil, bundle: nil)

        cardView.cardItems = cards
        cardView.delegate = self

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
            action: #selector(dismissPopup)
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
            action: #selector(dismissPopup)
        )

        backgroundTap.delegate = self

        view.addGestureRecognizer(backgroundTap)

        if transitionStyle == .slide {
            let backgroundSwipe = UISwipeGestureRecognizer(
                target: self,
                action: #selector(dismissPopup)
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Parra.logAnalyticsEvent(ParraSessionEventType.impression(
            location: "modal",
            module: ParraFeedback.self
        ), params: [
            "type": "popup"
        ])
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

    @objc private func dismissPopup() {
        dismiss(animated: true)
    }

    private func cardViewDismissedTransform() -> CGAffineTransform {
        return .identity.translatedBy(
            x: 0.0,
            y: view.bounds.height / 2 + cardView.bounds.height / 2
        )
    }
}

extension ParraCardPopupViewController: ParraCardViewDelegate {
    func parraCardViewDidRequestDismissal(_ parraCardView: ParraCardView) {
        dismissPopup()
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
