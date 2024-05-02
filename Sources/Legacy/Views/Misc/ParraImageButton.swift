//
//  ParraImageButton.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 10/15/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import UIKit

class ParraImageButton: UIControl, SelectableButton,
    ParraLegacyConfigurableView
{
    // MARK: - Lifecycle

    required init(
        initiallySelected: Bool,
        config: ParraCardViewConfig,
        asset: Asset
    ) {
        self.asset = asset

        self.buttonIsSelected = initiallySelected

        super.init(frame: .zero)

        setup(config: config)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal

    weak var delegate: SelectableButtonDelegate?
    var buttonIsSelected: Bool
    var allowsDeselection: Bool = false

    override var intrinsicContentSize: CGSize {
        return buttonImageView.intrinsicContentSize
    }

    func setup(config: ParraCardViewConfig) {
        addTarget(self, action: #selector(selectionAction), for: .touchUpInside)
        translatesAutoresizingMaskIntoConstraints = false

        buttonImageView.translatesAutoresizingMaskIntoConstraints = false
        buttonImageView.layer.cornerRadius = 8.0
        buttonImageView.layer.masksToBounds = true
        buttonImageView.contentMode = .scaleAspectFill

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true

        addSubview(buttonImageView)
        buttonImageView.addSubview(activityIndicator)

        NSLayoutConstraint.activate(
            buttonImageView.constrainEdgesWithVerticalCenteringPreference(
                to: self,
                with: .init(top: 8, left: 8, bottom: 8, right: 8)
            ) + [
                buttonImageView.widthAnchor
                    .constraint(equalTo: buttonImageView.heightAnchor),
                buttonImageView.widthAnchor.constraint(equalToConstant: 60),
//            buttonImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
//            buttonImageView.topAnchor.constraint(equalTo: topAnchor),
//            buttonImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
                activityIndicator.centerXAnchor
                    .constraint(equalTo: centerXAnchor),
                activityIndicator.centerYAnchor.constraint(
                    equalTo: centerYAnchor
                )
//            widthAnchor.constraint(equalTo: heightAnchor),
            ]
        )

//        Task {
//            let isCached = await Parra.getExistingInstance().apiResourceServer
//                .isAssetCached(
//                    asset: asset
//                )
//
//            if !isCached {
//                self.activityIndicator.startAnimating()
//            }
//
//            let image = try? await Parra.getExistingInstance().apiResourceServer
//                .fetchAsset(
//                    asset: asset
//                )
//
//            Task { @MainActor in
//                self.activityIndicator.stopAnimating()
//                buttonImageView.image = image
//            }
//        }

        applyConfig(config)
    }

    func applyConfig(_ config: ParraCardViewConfig) {
        backgroundColor = config.backgroundColor
        buttonImageView.layer.borderColor = config.tintColor?.cgColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        applyBorderStyleForSelection(animated: false, for: buttonImageView)
    }

    @objc
    func selectionAction(_ sender: ParraImageButton) {
        if allowsDeselection {
            buttonIsSelected = !buttonIsSelected
        } else if !buttonIsSelected {
            buttonIsSelected = true
        }

        applyBorderStyleForSelection(animated: true, for: buttonImageView)

        if buttonIsSelected {
            delegate?.buttonDidSelect(button: self)
        } else {
            delegate?.buttonDidDeselect(button: self)
        }
    }

    // MARK: - Private

    private let asset: Asset
    private var buttonImageView = UIImageView(frame: .zero)
    private var activityIndicator = UIActivityIndicatorView(style: .medium)
}
