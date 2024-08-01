//
//  ParraAttributes+Button.swift
//  Parra
//
//  Created by Mick MacCallum on 5/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraAttributes {
    struct PlainButton {
        // MARK: - Lifecycle

        public init(
            normal: StatefulAttributes = .init()
        ) {
            self.normal = normal
            self.pressed = normal.mergingOverrides(
                StatefulAttributes(
                    label: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            color: normal.label.text.color?.opacity(0.8)
                        )
                    )
                )
            )
            self.disabled = normal.mergingOverrides(
                StatefulAttributes(
                    label: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            color: normal.label.text.color?.opacity(0.6)
                        )
                    )
                )
            )
        }

        public init(
            normal: StatefulAttributes = .init(),
            pressed: StatefulAttributes = .init(),
            disabled: StatefulAttributes = .init()
        ) {
            self.normal = normal
            self.pressed = pressed
            self.disabled = disabled
        }

        // MARK: - Public

        // No background, handled by theme/type/variant
        public struct StatefulAttributes {
            // MARK: - Lifecycle

            public init(
                label: ParraAttributes.Label = .init(),
                cornerRadius: ParraCornerRadiusSize? = nil,
                padding: ParraPaddingSize? = nil
            ) {
                self.label = label
                self.cornerRadius = cornerRadius
                self.padding = padding
            }

            // MARK: - Public

            public internal(set) var label: ParraAttributes.Label
            public internal(set) var cornerRadius: ParraCornerRadiusSize?
            public internal(set) var padding: ParraPaddingSize?
        }

        public internal(set) var normal: StatefulAttributes
        public internal(set) var pressed: StatefulAttributes
        public internal(set) var disabled: StatefulAttributes
    }

    struct OutlinedButton {
        // MARK: - Lifecycle

        public init(
            normal: StatefulAttributes = .init()
        ) {
            self.normal = normal
            self.pressed = normal.mergingOverrides(
                StatefulAttributes(
                    label: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            color: normal.label.text.color?.opacity(0.8)
                        )
                    )
                )
            )
            self.disabled = normal.mergingOverrides(
                StatefulAttributes(
                    label: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            color: normal.label.text.color?.opacity(0.6)
                        )
                    )
                )
            )
        }

        public init(
            normal: StatefulAttributes = .init(),
            pressed: StatefulAttributes = .init(),
            disabled: StatefulAttributes = .init()
        ) {
            self.normal = normal
            self.pressed = pressed
            self.disabled = disabled
        }

        // MARK: - Public

        // No background, handled by theme/type/variant
        public struct StatefulAttributes {
            // MARK: - Lifecycle

            public init(
                label: ParraAttributes.Label = .init(),
                border: ParraAttributes.Border = .init(),
                cornerRadius: ParraCornerRadiusSize? = nil,
                padding: ParraPaddingSize? = nil
            ) {
                self.label = label
                self.border = border
                self.cornerRadius = cornerRadius
                self.padding = padding
            }

            // MARK: - Public

            public internal(set) var label: ParraAttributes.Label
            public internal(set) var border: ParraAttributes.Border
            public internal(set) var cornerRadius: ParraCornerRadiusSize?
            public internal(set) var padding: ParraPaddingSize?
        }

        public internal(set) var normal: StatefulAttributes
        public internal(set) var pressed: StatefulAttributes
        public internal(set) var disabled: StatefulAttributes
    }

    struct ContainedButton {
        // MARK: - Lifecycle

        public init(
            normal: StatefulAttributes = .init()
        ) {
            self.normal = normal
            self.pressed = normal.mergingOverrides(
                StatefulAttributes(
                    label: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            color: normal.label.text.color?.opacity(0.8)
                        ),
                        background: normal.label.background?.opacity(0.8)
                    )
                )
            )
            self.disabled = normal.mergingOverrides(
                StatefulAttributes(
                    label: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            color: normal.label.text.color?.opacity(0.6)
                        ),
                        background: normal.label.background?.opacity(0.6)
                    )
                )
            )
        }

        public init(
            normal: StatefulAttributes = .init(),
            pressed: StatefulAttributes = .init(),
            disabled: StatefulAttributes = .init()
        ) {
            self.normal = normal
            self.pressed = pressed
            self.disabled = disabled
        }

        // MARK: - Public

        // No background, handled by theme/type/variant
        public struct StatefulAttributes {
            // MARK: - Lifecycle

            public init(
                label: ParraAttributes.Label = .init(),
                border: ParraAttributes.Border = .init(),
                cornerRadius: ParraCornerRadiusSize? = nil,
                padding: ParraPaddingSize? = nil
            ) {
                self.label = label
                self.border = border
                self.cornerRadius = cornerRadius
                self.padding = padding
            }

            // MARK: - Public

            public internal(set) var label: ParraAttributes.Label
            public internal(set) var border: ParraAttributes.Border
            public internal(set) var cornerRadius: ParraCornerRadiusSize?
            public internal(set) var padding: ParraPaddingSize?
        }

        public internal(set) var normal: StatefulAttributes
        public internal(set) var pressed: StatefulAttributes
        public internal(set) var disabled: StatefulAttributes
    }

    struct ImageButton {
        // MARK: - Lifecycle

        public init(
            normal: StatefulAttributes = .init()
        ) {
            self.normal = normal
            self.pressed = normal.mergingOverrides(
                StatefulAttributes(
                    image: ParraAttributes.Image(
                        tint: normal.image.tint?.opacity(0.8)
                    )
                )
            )
            self.disabled = normal.mergingOverrides(
                StatefulAttributes(
                    image: ParraAttributes.Image(
                        tint: normal.image.tint?.opacity(0.6)
                    )
                )
            )
        }

        public init(
            normal: StatefulAttributes = .init(),
            pressed: StatefulAttributes = .init(),
            disabled: StatefulAttributes = .init()
        ) {
            self.normal = normal
            self.pressed = pressed
            self.disabled = disabled
        }

        // MARK: - Public

        public struct StatefulAttributes {
            // MARK: - Lifecycle

            public init(
                image: ParraAttributes.Image = .init(),
                border: ParraAttributes.Border = .init(),
                cornerRadius: ParraCornerRadiusSize? = nil,
                padding: ParraPaddingSize? = nil
            ) {
                self.image = image
                self.border = border
                self.cornerRadius = cornerRadius
                self.padding = padding
            }

            // MARK: - Public

            public internal(set) var image: ParraAttributes.Image

            public internal(set) var border: ParraAttributes.Border
            public internal(set) var cornerRadius: ParraCornerRadiusSize?
            public internal(set) var padding: ParraPaddingSize?
        }

        public internal(set) var normal: StatefulAttributes
        public internal(set) var pressed: StatefulAttributes
        public internal(set) var disabled: StatefulAttributes
    }
}

// MARK: - ParraAttributes.OutlinedButton + OverridableAttributes

extension ParraAttributes.OutlinedButton: OverridableAttributes {
    func mergingOverrides(
        _ overrides: ParraAttributes.OutlinedButton?
    ) -> ParraAttributes.OutlinedButton {
        return ParraAttributes.OutlinedButton(
            normal: ParraAttributes.OutlinedButton.StatefulAttributes(
                label: normal.label.mergingOverrides(overrides?.normal.label),
                border: normal.border
                    .mergingOverrides(overrides?.normal.border),
                cornerRadius: overrides?.normal.cornerRadius ?? normal
                    .cornerRadius,
                padding: overrides?.normal.padding ?? normal.padding
            ),
            pressed: ParraAttributes.OutlinedButton.StatefulAttributes(
                label: pressed.label.mergingOverrides(overrides?.pressed.label),
                border: pressed.border
                    .mergingOverrides(overrides?.pressed.border),
                cornerRadius: overrides?.pressed.cornerRadius ?? pressed
                    .cornerRadius,
                padding: overrides?.pressed.padding ?? pressed.padding
            ),
            disabled: ParraAttributes.OutlinedButton.StatefulAttributes(
                label: disabled.label
                    .mergingOverrides(overrides?.disabled.label),
                border: disabled.border
                    .mergingOverrides(overrides?.disabled.border),
                cornerRadius: overrides?.disabled.cornerRadius ?? disabled
                    .cornerRadius,
                padding: overrides?.disabled.padding ?? disabled.padding
            )
        )
    }
}

// MARK: - ParraAttributes.PlainButton + OverridableAttributes

extension ParraAttributes.PlainButton: OverridableAttributes {
    func mergingOverrides(
        _ overrides: ParraAttributes.PlainButton?
    ) -> ParraAttributes.PlainButton {
        return ParraAttributes.PlainButton(
            normal: ParraAttributes.PlainButton.StatefulAttributes(
                label: normal.label.mergingOverrides(overrides?.normal.label),
                cornerRadius: overrides?.normal.cornerRadius ?? normal
                    .cornerRadius,
                padding: overrides?.normal.padding ?? normal.padding
            ),
            pressed: ParraAttributes.PlainButton.StatefulAttributes(
                label: pressed.label.mergingOverrides(overrides?.pressed.label),
                cornerRadius: overrides?.pressed.cornerRadius ?? pressed
                    .cornerRadius,
                padding: overrides?.pressed.padding ?? pressed.padding
            ),
            disabled: ParraAttributes.PlainButton.StatefulAttributes(
                label: disabled.label
                    .mergingOverrides(overrides?.disabled.label),
                cornerRadius: overrides?.disabled.cornerRadius ?? disabled
                    .cornerRadius,
                padding: overrides?.disabled.padding ?? disabled.padding
            )
        )
    }
}

// MARK: - ParraAttributes.ContainedButton + OverridableAttributes

extension ParraAttributes.ContainedButton: OverridableAttributes {
    func mergingOverrides(
        _ overrides: ParraAttributes.ContainedButton?
    ) -> ParraAttributes.ContainedButton {
        return ParraAttributes.ContainedButton(
            normal: ParraAttributes.ContainedButton.StatefulAttributes(
                label: normal.label.mergingOverrides(overrides?.normal.label),
                border: normal.border
                    .mergingOverrides(overrides?.normal.border),
                cornerRadius: overrides?.normal.cornerRadius ?? normal
                    .cornerRadius,
                padding: overrides?.normal.padding ?? normal.padding
            ),
            pressed: ParraAttributes.ContainedButton.StatefulAttributes(
                label: pressed.label.mergingOverrides(overrides?.pressed.label),
                border: pressed.border
                    .mergingOverrides(overrides?.pressed.border),
                cornerRadius: overrides?.pressed.cornerRadius ?? pressed
                    .cornerRadius,
                padding: overrides?.pressed.padding ?? pressed.padding
            ),
            disabled: ParraAttributes.ContainedButton.StatefulAttributes(
                label: disabled.label
                    .mergingOverrides(overrides?.disabled.label),
                border: disabled.border
                    .mergingOverrides(overrides?.disabled.border),
                cornerRadius: overrides?.disabled.cornerRadius ?? disabled
                    .cornerRadius,
                padding: overrides?.disabled.padding ?? disabled.padding
            )
        )
    }
}

// MARK: - ParraAttributes.ContainedButton + OverridableAttributes

extension ParraAttributes.ContainedButton
    .StatefulAttributes: OverridableAttributes
{
    func mergingOverrides(
        _ overrides: ParraAttributes.ContainedButton.StatefulAttributes?
    ) -> ParraAttributes.ContainedButton.StatefulAttributes {
        return ParraAttributes.ContainedButton.StatefulAttributes(
            label: label.mergingOverrides(overrides?.label),
            border: border.mergingOverrides(overrides?.border),
            cornerRadius: overrides?.cornerRadius ?? cornerRadius,
            padding: overrides?.padding ?? padding
        )
    }
}

// MARK: - ParraAttributes.OutlinedButton + OverridableAttributes

extension ParraAttributes.OutlinedButton
    .StatefulAttributes: OverridableAttributes
{
    func mergingOverrides(
        _ overrides: ParraAttributes.OutlinedButton.StatefulAttributes?
    ) -> ParraAttributes.OutlinedButton.StatefulAttributes {
        return ParraAttributes.OutlinedButton.StatefulAttributes(
            label: label.mergingOverrides(overrides?.label),
            border: border.mergingOverrides(overrides?.border),
            cornerRadius: overrides?.cornerRadius ?? cornerRadius,
            padding: overrides?.padding ?? padding
        )
    }
}

// MARK: - ParraAttributes.PlainButton + OverridableAttributes

extension ParraAttributes.PlainButton
    .StatefulAttributes: OverridableAttributes
{
    func mergingOverrides(
        _ overrides: ParraAttributes.PlainButton.StatefulAttributes?
    ) -> ParraAttributes.PlainButton.StatefulAttributes {
        return ParraAttributes.PlainButton.StatefulAttributes(
            label: label.mergingOverrides(overrides?.label),
            cornerRadius: overrides?.cornerRadius ?? cornerRadius,
            padding: overrides?.padding ?? padding
        )
    }
}

// MARK: - ParraAttributes.ImageButton + OverridableAttributes

extension ParraAttributes.ImageButton: OverridableAttributes {
    func mergingOverrides(
        _ overrides: ParraAttributes.ImageButton?
    ) -> ParraAttributes.ImageButton {
        return ParraAttributes.ImageButton(
            normal: ParraAttributes.ImageButton.StatefulAttributes(
                image: normal.image.mergingOverrides(overrides?.normal.image),
                border: normal.border
                    .mergingOverrides(overrides?.normal.border),
                cornerRadius: overrides?.normal.cornerRadius ?? normal
                    .cornerRadius,
                padding: overrides?.normal.padding ?? normal.padding
            ),
            pressed: ParraAttributes.ImageButton.StatefulAttributes(
                image: pressed.image.mergingOverrides(overrides?.pressed.image),
                border: pressed.border
                    .mergingOverrides(overrides?.pressed.border),
                cornerRadius: overrides?.pressed.cornerRadius ?? pressed
                    .cornerRadius,
                padding: overrides?.pressed.padding ?? pressed.padding
            ),
            disabled: ParraAttributes.ImageButton.StatefulAttributes(
                image: disabled.image
                    .mergingOverrides(overrides?.disabled.image),
                border: disabled.border
                    .mergingOverrides(overrides?.disabled.border),
                cornerRadius: overrides?.disabled.cornerRadius ?? disabled
                    .cornerRadius,
                padding: overrides?.disabled.padding ?? disabled.padding
            )
        )
    }
}

// MARK: - ParraAttributes.ImageButton + OverridableAttributes

extension ParraAttributes.ImageButton
    .StatefulAttributes: OverridableAttributes
{
    func mergingOverrides(
        _ overrides: ParraAttributes.ImageButton.StatefulAttributes?
    ) -> ParraAttributes.ImageButton.StatefulAttributes {
        return ParraAttributes.ImageButton.StatefulAttributes(
            image: image.mergingOverrides(overrides?.image),
            border: border.mergingOverrides(overrides?.border),
            cornerRadius: overrides?.cornerRadius ?? cornerRadius,
            padding: overrides?.padding ?? padding
        )
    }
}
