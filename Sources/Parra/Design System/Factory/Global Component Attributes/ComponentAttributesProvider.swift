//
//  ComponentAttributesProvider.swift
//  Parra
//
//  Created by Mick MacCallum on 5/3/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public protocol ComponentAttributesProvider {
    // MARK: Labels

    func labelAttributes(
        for textStyle: ParraTextStyle,
        theme: ParraTheme
    ) -> ParraAttributes.Label

    // MARK: Buttons

    func plainButtonAttributes(
        in state: ParraButtonState,
        for size: ParraButtonSize,
        with type: ParraButtonType,
        theme: ParraTheme
    ) -> ParraAttributes.PlainButton

    func outlinedButtonAttributes(
        in state: ParraButtonState,
        for size: ParraButtonSize,
        with type: ParraButtonType,
        theme: ParraTheme
    ) -> ParraAttributes.OutlinedButton

    func containedButtonAttributes(
        in state: ParraButtonState,
        for size: ParraButtonSize,
        with type: ParraButtonType,
        theme: ParraTheme
    ) -> ParraAttributes.ContainedButton
}
