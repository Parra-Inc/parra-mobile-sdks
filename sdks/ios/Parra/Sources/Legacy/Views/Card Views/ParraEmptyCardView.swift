//
//  ParraEmptyCardView.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 3/16/22.
//

import Foundation
import UIKit

class ParraEmptyCardView: ParraCardItemView {
    init(innerView: UIView) {
        super.init(config: .default)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(config: ParraCardViewConfig) {
        fatalError("init(config:) has not been implemented")
    }
}
