//
//  ParraFeedbackCollectionViewCell.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 5/16/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import UIKit
import ParraCore

/// <#Description#>
public class ParraFeedbackCollectionViewCell: UICollectionViewCell {

    /// <#Description#>
    public weak var delegate: ParraFeedbackViewDelegate?

    /// <#Description#>
    public static let defaultCellId = "ParraFeedbackCollectionViewCell"
    
    /// <#Description#>
    public var config: ParraFeedbackViewConfig = .default {
        didSet {
            parraFeedbackView.config = config
        }
    }

    private let parraFeedbackView = ParraFeedbackView(config: .default)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }

    /// <#Description#>
    public func endDisplaying() {
        Parra.triggerSync()
    }
        
    private func commonInit() {
        contentView.addSubview(parraFeedbackView)

        NSLayoutConstraint.activate([
            parraFeedbackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            parraFeedbackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            parraFeedbackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            parraFeedbackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
}
