//
//  ParraImageButton.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 10/15/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import UIKit
import ParraCore

internal class ParraImageButton: UIButton, SelectableButton {
    enum Style {
        static let outer: CGFloat = 18
        static let inner: CGFloat = 9
        static let lineWidth: CGFloat = 2.5
        static let padding: CGFloat = 0
    }

    internal weak var delegate: SelectableButtonDelegate?
    internal var buttonIsSelected: Bool
    internal var allowsDeselection: Bool = false
    private let config: ParraFeedbackViewConfig
    private var asset: Asset?
    private var buttonImageView = UIImageView(frame: .zero)
    private var activityIndicator = UIActivityIndicatorView(style: .medium)

    internal required init(initiallySelected: Bool,
                           config: ParraFeedbackViewConfig,
                           asset: Asset?) {
        self.asset = asset
        self.config = config
        buttonIsSelected = initiallySelected

        super.init(frame: .zero)

        setup()
    }

    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal override func layoutSubviews() {
        super.layoutSubviews()

        updateSelectionState(animated: false)
    }

    internal func setup() {
        addTarget(self, action: #selector(selectionAction), for: .touchUpInside)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = config.backgroundColor

        buttonImageView.backgroundColor = .white
        buttonImageView.translatesAutoresizingMaskIntoConstraints = false
        buttonImageView.layer.cornerRadius = 8.0
        buttonImageView.layer.masksToBounds = true
        buttonImageView.contentMode = .scaleAspectFill

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true

        addSubview(buttonImageView)
        buttonImageView.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            buttonImageView.widthAnchor.constraint(equalTo: buttonImageView.heightAnchor),
            buttonImageView.widthAnchor.constraint(equalToConstant: 70),
            buttonImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            buttonImageView.topAnchor.constraint(equalTo: topAnchor),
            buttonImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        if let asset = asset {
            Task {
                let isCached = Parra.Assets.isAssetCached(asset: asset)

                if !isCached {
                    self.activityIndicator.startAnimating()
                }

                let image = try? await Parra.Assets.fetchAsset(asset: asset)

                self.activityIndicator.stopAnimating()
                buttonImageView.image = image
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        return buttonImageView.intrinsicContentSize
    }

    @objc internal func selectionAction(_ sender: ParraRadioButton) {
        if allowsDeselection {
            buttonIsSelected = !buttonIsSelected
        } else if !buttonIsSelected {
            buttonIsSelected = true
        }

        if buttonIsSelected {
            delegate?.buttonDidSelect(button: self)
        } else {
            delegate?.buttonDidDeselect(button: self)
        }
    }

    internal func updateSelectionState(animated: Bool) {
        // TODO: Border color
    }
}
