//
//  ParraStarButton.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 1/4/22.
//

import UIKit

class ParraStarButton: UIButton, SelectableButton {
    var delegate: SelectableButtonDelegate?
    var buttonIsSelected: Bool
    var allowsDeselection: Bool = false

    required init(initiallySelected: Bool) {
        buttonIsSelected = initiallySelected
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
