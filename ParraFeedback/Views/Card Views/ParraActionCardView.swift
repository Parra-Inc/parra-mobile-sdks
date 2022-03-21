//
//  ParraActionCardView.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 11/23/21.
//

import UIKit

class ParraActionCardView: ParraCardView {
    private let titleLabel = UILabel(frame: .zero)
    private let subtitleLabel = UILabel(frame: .zero)
    // TODO: De-scoped for now.
//    private var cta = UIButton(type: .system)
    private let stackView = UIStackView(arrangedSubviews: [])
    private var actionHandler: (() -> Void)?
    

    required init(
        title: String,
        subtitle: String?,
        actionTitle: String,
        actionHandler: (() -> Void)?
    ) {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false

        self.actionHandler = actionHandler
        
        stackView.addArrangedSubview(titleLabel)
        if let subtitle = subtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel.font = .preferredFont(forTextStyle: .callout)

            stackView.addArrangedSubview(subtitleLabel)
        }
//        stackView.addArrangedSubview(cta)
        
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            // visually centered
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -ParraFeedbackView.LayoutConstants.navigationPadding),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 0),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: 0),
        ])
                
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
//        cta.addTarget(self, action: #selector(ctaPressed(button:)), for: .touchUpInside)
//
//        let attributedTitle = NSAttributedString(
//            string: actionTitle,
//            attributes: [.font: UIFont.boldSystemFont(ofSize: 14)]
//        )
//        cta.setAttributedTitle(attributedTitle, for: .normal)
//        cta.translatesAutoresizingMaskIntoConstraints = false
//        cta.setTitleColor(UIColor(hex: 0xBDBDBD), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    @objc private func ctaPressed(button: UIButton) {
        if let actionHandler = actionHandler {
            actionHandler()
        }
    }
}
