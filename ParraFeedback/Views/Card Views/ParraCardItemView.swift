//
//  ParraCardItemView.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 11/28/21.
//

import Foundation
import UIKit

// TODO: Common ancestor. Might be able to just be a protocol.
public class ParraCardItemView: UIView, ParraConfigurableView {
    internal var config: ParraCardViewConfig
    
    internal required init(config: ParraCardViewConfig) {
        self.config = config
        
        super.init(frame: .zero)
        
        isUserInteractionEnabled = true
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applyConfig(_ config: ParraCardViewConfig) {

    }
}
