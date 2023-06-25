//
//  ParraCardPopupViewController.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import UIKit

internal class ParraCardPopupViewController: ParraCardModalViewController, ParraCardModal {
    private var userDismissable = true

    convenience init(
        cards: [ParraCardItem],
        config: ParraCardViewConfig,
        transitionStyle: ParraCardModalTransitionStyle,
        userDismissable: Bool = true,
        onDismiss: (() -> Void)? = nil
    ) {
        self.init(
            cards: cards,
            config: config,
            transitionStyle: transitionStyle,
            onDismiss: onDismiss
        )
        self.userDismissable = userDismissable
    }

    required init(
        cards: [ParraCardItem],
        config: ParraCardViewConfig,
        transitionStyle: ParraCardModalTransitionStyle,
        onDismiss: (() -> Void)? = nil
    ) {
        super.init(
            cards: cards,
            config: config,
            transitionStyle: transitionStyle,
            modalType: .popup,
            onDismiss: onDismiss
        )

        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black.withAlphaComponent(0.3)
        view.addSubview(cardView)

        let centerYAnchor = cardView.centerYAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.centerYAnchor
        )
        centerYAnchor.priority = .init(900)

        var constraints = [
            centerYAnchor,
            cardView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor
            ),
            cardView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor
            ),
        ]

        if userDismissable {
            let dismissButton = UIButton.systemButton(
                // Works on all app versions within deploy target
                with: UIImage(systemName: "xmark")!,
                target: self,
                action: #selector(dismissModal)
            )

            dismissButton.tintColor = cardView.config.tintColor
            dismissButton.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(dismissButton)

            constraints.append(contentsOf: [
                dismissButton.topAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.topAnchor,
                    constant: 16
                ),
                dismissButton.trailingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                    constant: -24
                )
            ])
        }

        let keyboardAvoidingAnchor = cardView.bottomAnchor.constraint(
            lessThanOrEqualTo: view.keyboardLayoutGuide.topAnchor
        )

        keyboardAvoidingAnchor.priority = .required

        constraints.append(keyboardAvoidingAnchor)

        NSLayoutConstraint.activate(constraints)

        if userDismissable {
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
