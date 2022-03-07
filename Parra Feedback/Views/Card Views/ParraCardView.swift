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
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
