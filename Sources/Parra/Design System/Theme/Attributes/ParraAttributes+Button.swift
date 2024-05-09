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
        // No background, handled by theme/type/variant
        public struct StatefulAttributes {
            public internal(set) var label: ParraAttributes.Label
            public internal(set) var cornerRadius: ParraCornerRadiusSize
            public internal(set) var padding: ParraPaddingSize
        }

        public internal(set) var normal: StatefulAttributes
        public internal(set) var pressed: StatefulAttributes
        public internal(set) var disabled: StatefulAttributes
    }

    struct OutlinedButton {
        // No background, handled by theme/type/variant
        public struct StatefulAttributes {
            public internal(set) var label: ParraAttributes.Label
            public internal(set) var border: ParraAttributes.Border
            public internal(set) var cornerRadius: ParraCornerRadiusSize
            public internal(set) var padding: ParraPaddingSize
        }

        public internal(set) var normal: StatefulAttributes
        public internal(set) var pressed: StatefulAttributes
        public internal(set) var disabled: StatefulAttributes
    }

    struct ContainedButton {
        // No background, handled by theme/type/variant
        public struct StatefulAttributes {
            public internal(set) var label: ParraAttributes.Label
            public internal(set) var border: ParraAttributes.Border
            public internal(set) var cornerRadius: ParraCornerRadiusSize
            public internal(set) var padding: ParraPaddingSize
        }

        public internal(set) var normal: StatefulAttributes
        public internal(set) var pressed: StatefulAttributes
        public internal(set) var disabled: StatefulAttributes
    }

    struct ImageButton {
        public struct StatefulAttributes {
            public internal(set) var image: ParraAttributes.Image

            public internal(set) var border: ParraAttributes.Border
            public internal(set) var cornerRadius: ParraCornerRadiusSize
            public internal(set) var padding: ParraPaddingSize
        }

        public internal(set) var normal: StatefulAttributes
        public internal(set) var pressed: StatefulAttributes
        public internal(set) var disabled: StatefulAttributes
    }
}
