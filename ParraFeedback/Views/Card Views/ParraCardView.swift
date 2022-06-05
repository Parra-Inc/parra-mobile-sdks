//
//  ParraCard.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 11/28/21.
//

import Foundation
import UIKit

// TODO: Common ancestor. Might be able to just be a protocol.
public class ParraCardView: UIView {
    internal var config: ParraFeedbackViewConfig
    
    internal required init(config: ParraFeedbackViewConfig) {
        self.config = config
        
        super.init(frame: .zero)
        
        isUserInteractionEnabled = true
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
