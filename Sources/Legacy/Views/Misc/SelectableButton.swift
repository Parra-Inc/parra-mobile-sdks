//
//  SelectableButton.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 12/29/21.
//

import UIKit

protocol SelectableButtonDelegate: AnyObject {
    func buttonDidSelect(button: SelectableButton)
    func buttonDidDeselect(button: SelectableButton)
}

protocol SelectableButton: ParraLegacyConfigurableView {
    var delegate: SelectableButtonDelegate? { get set }
    var buttonIsSelected: Bool { get set }
    var allowsDeselection: Bool { get set }
}

extension SelectableButton {
    func applyBorderStyleForSelection(
        animated: Bool,
        for view: UIView,
        selectedRadius: CGFloat = 1.5,
        completion: (() -> Void)? = nil
    ) {
        let performBorderUpdates = { [self] in
            view.layer.borderWidth = buttonIsSelected ? 1.5 : 0
        }

        if animated {
            UIView.animate(
                withDuration: 0.2,
                delay: 0.0,
                options: [.beginFromCurrentState, .allowUserInteraction],
                animations: {
                    performBorderUpdates()
                }
            ) { _ in
                completion?()
            }
        } else {
            performBorderUpdates()
            completion?()
        }
    }
}
