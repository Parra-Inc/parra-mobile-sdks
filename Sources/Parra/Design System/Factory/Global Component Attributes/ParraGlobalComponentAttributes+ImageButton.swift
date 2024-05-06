//
//  ParraGlobalComponentAttributes+ImageButton.swift
//  Parra
//
//  Created by Mick MacCallum on 5/6/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraGlobalComponentAttributes {
    func imageButtonAttributes(
        in state: ParraButtonState,
        for size: ParraImageButtonSize,
        with type: ParraButtonType,
        theme: ParraTheme
    ) -> ParraAttributes.ImageButton {
        return ParraAttributes.ImageButton(
            image: ParraAttributes.Image(),
            border: .init(),
            cornerRadius: .md,
            padding: .md
        )
    }
}
