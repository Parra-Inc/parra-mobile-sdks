//
//  ParraFeedbackTableViewCell.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 3/29/22.
//

import UIKit

class ParraFeedbackTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        selectionStyle = .none
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override var selectionStyle: UITableViewCell.SelectionStyle {
        didSet {
            if selectionStyle != .none {
                selectionStyle = .none
            }
        }
    }
}
