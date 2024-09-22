//
//  ParraUserProperties+MergeConflict.swift
//  Parra
//
//  Created by Mick MacCallum on 9/22/24.
//

import Foundation

public extension ParraUserProperties {
    struct MergeConflict {
        // MARK: - Lifecycle

        init(
            key: String,
            oldValue: ParraAnyCodable,
            newValue: ParraAnyCodable,
            resolver: @escaping (MergeConflict, Resolution) -> Void
        ) {
            self.key = key
            self.oldValue = oldValue
            self.newValue = newValue
            self.resolver = resolver
        }

        // MARK: - Public

        public enum Resolution {
            case keepOld
            case keepNew
        }

        public let key: String
        public let oldValue: ParraAnyCodable
        public let newValue: ParraAnyCodable

        /// Decides which resolution strategy should be used to resolve
        /// the conflict.
        public func resolve(_ resolution: Resolution) {
            resolver(self, resolution)
        }

        // MARK: - Internal

        let resolver: (MergeConflict, Resolution) -> Void
    }
}
