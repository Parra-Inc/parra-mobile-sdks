//
//  ParraCardItemView.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 11/28/21.
//

import Foundation
import UIKit

class ParraCardItemView: UIView, ParraLegacyConfigurableView {
    // MARK: - Lifecycle

    required init(config: ParraCardViewConfig) {
        self.config = config

        super.init(frame: .zero)

        isUserInteractionEnabled = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal

    var config: ParraCardViewConfig

    func applyConfig(_ config: ParraCardViewConfig) {}

    /// An external action has informed the card that it should commit any pending changes. This may indicate the user
    /// has taken an action that is causing navigation away from the card.
    func commitToSelection() {
        assertionFailure(
            "Subclasses of ParraCardItemView should override commitToSelection"
        )
    }
}
