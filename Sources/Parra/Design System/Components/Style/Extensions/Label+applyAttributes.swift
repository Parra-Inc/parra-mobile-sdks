//
//  Label+applyAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 5/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension LabelComponent {
    func applyFormTitleAttributes() -> some View {
        foregroundStyle(themeObserver.theme.palette.primaryText.toParraColor())
            .fontWeight(.medium)
            .padding(.bottom, 10)
            .padding(.trailing, 2)
    }

    func applyFormHelperAttributes(erroring: Bool = false) -> some View {
        let fontColor = erroring
            ? themeObserver.theme.palette.error.toParraColor()
            : themeObserver.theme.palette.secondaryText.toParraColor()

        return foregroundStyle(fontColor)
            .padding(.top, 3)
            .padding(.trailing, 2)
            .frame(
                maxWidth: .infinity,
                minHeight: 12,
                idealHeight: 12,
                maxHeight: 12,
                alignment: .trailing
            )
    }

    func applyFormCalloutAttributes(erroring: Bool = false) -> some View {
        let fontColor = erroring
            ? themeObserver.theme.palette.error.toParraColor()
            : themeObserver.theme.palette.secondaryText.toParraColor()

        return foregroundStyle(fontColor.opacity(0.8))
    }
}
