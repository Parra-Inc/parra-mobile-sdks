//
//  ParraFeedbackTableViewCell.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 3/29/22.
//

import UIKit

/// <#Description#>
public class ParraFeedbackTableViewCell: UITableViewCell {

    /// <#Description#>
    public static let defaultCellId = "ParraFeedbackTableViewCell"
    
    /// <#Description#>
    public var config: ParraFeedbackViewConfig = .default {
        didSet {
            parraFeedbackView.config = config
        }
    }

    private let parraFeedbackView = ParraFeedbackView(
        cardItems: [],
        config: .default
    )
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
            
    public override var selectionStyle: UITableViewCell.SelectionStyle {
        didSet {
            if selectionStyle != .none {
                selectionStyle = .none
            }
        }
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    private func commonInit() {
        selectionStyle = .none
        
        contentView.addSubview(parraFeedbackView)
        
        NSLayoutConstraint.activate([
            parraFeedbackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            parraFeedbackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            parraFeedbackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            parraFeedbackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

}
