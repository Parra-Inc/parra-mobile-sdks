//
//  ParraStarButton.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 1/4/22.
//

import UIKit

internal class ParraStarButton: UIButton, SelectableButton {
    internal weak var delegate: SelectableButtonDelegate?
    internal var buttonIsSelected: Bool
    internal var allowsDeselection: Bool = false
    
    internal required init(initiallySelected: Bool) {
        buttonIsSelected = initiallySelected
        super.init(frame: .zero)
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
