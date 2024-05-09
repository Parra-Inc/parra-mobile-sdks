//
//  ParraAttributes+Alert.swift
//  Parra
//
//  Created by Mick MacCallum on 5/9/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraAttributes {
    struct InlineAlert {
        public let title: ParraAttributes.Label
        public let subtitle: ParraAttributes.Label
        public let icon: ParraAttributes.Image

        public internal(set) var border: ParraAttributes.Border
        public internal(set) var cornerRadius: ParraCornerRadiusSize
        public internal(set) var padding: ParraPaddingSize
        public internal(set) var background: Color?
    }

    struct ToastAlert {
        public let title: ParraAttributes.Label
        public let subtitle: ParraAttributes.Label
        public let icon: ParraAttributes.Image
        public let dismissButton: ParraAttributes.ImageButton

        public internal(set) var border: ParraAttributes.Border
        public internal(set) var cornerRadius: ParraCornerRadiusSize
        public internal(set) var padding: ParraPaddingSize
        public internal(set) var background: Color?
    }
}
