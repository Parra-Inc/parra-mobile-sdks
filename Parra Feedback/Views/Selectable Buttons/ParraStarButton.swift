//
//  ParraStarButton.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 1/4/22.
//

import UIKit

class ParraStarButton: UIButton, SelectableButton {
    var delegate: SelectableButtonDelegate?
    var buttonIsSelected: Bool = false
    var allowsDeselection: Bool = false
}
