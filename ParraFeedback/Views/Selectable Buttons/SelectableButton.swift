//
//  SelectableButton.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 12/29/21.
//

import Foundation

internal protocol SelectableButtonDelegate: AnyObject {
    func buttonDidSelect(button: SelectableButton)
    func buttonDidDeselect(button: SelectableButton)
}

internal protocol SelectableButton: AnyObject {
    init(initiallySelected: Bool)
    
    var delegate: SelectableButtonDelegate? { get set }
    
    var buttonIsSelected: Bool { get set }
    
    var allowsDeselection: Bool { get set }
}
