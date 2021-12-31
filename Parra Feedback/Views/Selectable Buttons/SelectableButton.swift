//
//  SelectableButton.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 12/29/21.
//

import Foundation

protocol SelectableButtonDelegate: NSObjectProtocol {
    func buttonDidSelect(button: SelectableButton)
    func buttonDidDeselect(button: SelectableButton)
}

protocol SelectableButton: NSObjectProtocol {
    var delegate: SelectableButtonDelegate? { get set }

    var buttonIsSelected: Bool { get set }

    var allowsDeselection: Bool { get set }
}
