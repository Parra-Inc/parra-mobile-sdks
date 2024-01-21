//
//  View+ApplyConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 1/24/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// NOTE: This file intentionally includes some redundancy between the code included
//       in the various applyViewConfig(:) overloads. Different views can require
//       subtle differences in modifier ordering that are preventing much more abstraction.

extension View {
    @ViewBuilder
    func applyViewConfig(
        _ viewConfig: ParraViewConfig?
    ) -> some View {
        ifNotNil(value: viewConfig) { viewConfig, base in
            ifNotNil(value: viewConfig.background) { value, element in
                element.applyBackground(value)
            }
            .ifNotNil(value: viewConfig.cornerRadius) { value, element in
                element.applyCornerRadii(value)
            }
            .ifNotNil(value: viewConfig.padding) { value, element in
                element.padding(value)
            }
        }
    }

    @ViewBuilder
    func applyViewConfig(
        _ viewConfig: ParraLabelViewConfig?
    ) -> some View {
        ifNotNil(value: viewConfig) { viewConfig, base in
            base.ifNotNil(value: viewConfig.padding) { value, element in
                element.padding(value)
            }
            .ifNotNil(value: viewConfig.background) { value, element in
                element.applyBackground(value)
            }
            .ifNotNil(value: viewConfig.cornerRadius) { value, element in
                element.applyCornerRadii(value)
            }
            .font(viewConfig.font)
            .ifNotNil(value: viewConfig.color) { value, element in
                element.foregroundStyle(value)
            }
        }
    }

    @ViewBuilder
    func applyViewConfig(
        _ viewConfig: ParraButtonViewConfig?,
        variant: ParraButtonVariant,
        size: ParraButtonSize
    ) -> some View {
        ifNotNil(value: viewConfig) { viewConfig, base in
            base.if(size == .large) { element in
                element.frame(maxWidth: .infinity)
            }
            .if(variant == .outlined) { element in
                element.overlay(
                    UnevenRoundedRectangle(
                        cornerRadii: viewConfig.cornerRadius ?? .zero,
                        style: .continuous
                    )
                    .stroke(.blue, lineWidth: 1)
                )
            }
            .ifNotNil(value: viewConfig.padding) { value, element in
                element.padding(value)
            }
            .ifNotNil(value: viewConfig.background) { value, element in
                element.applyBackground(value)
            }
            .ifNotNil(value: viewConfig.cornerRadius) { value, element in
                // Corner radius is applied to overlay stroke on this button style.
                element.if(variant != .outlined) { el in
                    el.applyCornerRadii(value)
                        .buttonBorderShape(.roundedRectangle)
                }
            }
        }
    }

    func applyCornerRadii(
        _ cornerRadii: RectangleCornerRadii?
    ) -> some View {
        return clipShape(
            UnevenRoundedRectangle(cornerRadii: cornerRadii ?? .zero)
        )
    }

    @ViewBuilder
    func applyBackground(
        _ background: (any ShapeStyle)?
    ) -> some View {
        let style = if let background {
            AnyShapeStyle(background)
        } else {
            AnyShapeStyle(.clear)
        }

        self.background(style)
    }

    @ViewBuilder
    func applyBackground(
        _ background: ParraBackground
    ) -> some View {
        if case let .color(color) = background {
            self.background(color)
        } else if case let .gradient(gradient) = background {
            self.background(gradient)
        } else {
            self
        }

        // TODO: Buttons use tint for background, views/text use background.
    }
}
