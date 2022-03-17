//
//  ParraEmptyCardView.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 3/16/22.
//

import Foundation
import UIKit

class ParraEmptyCardView: ParraCardView {
    internal init(innerView: UIView) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
