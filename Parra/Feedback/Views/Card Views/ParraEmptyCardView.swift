//
//  ParraEmptyCardView.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 3/16/22.
//

import Foundation
import UIKit

internal class ParraEmptyCardView: ParraCardItemView {
    internal init(innerView: UIView) {
        super.init(config: .default)
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal required init(config: ParraCardViewConfig) {
        fatalError("init(config:) has not been implemented")
    }
}
