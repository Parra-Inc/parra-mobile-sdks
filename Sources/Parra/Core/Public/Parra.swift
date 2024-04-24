//
//  Parra.swift
//  Parra
//
//  Created by Michael MacCallum on 11/22/21.
//

import SwiftUI

/// The primary module used to interact with the Parra SDK.
/// Access this module via the `parra` `@Environment` object in SwiftUI after
/// wrapping your `Scene` in the ``ParraApp`` View.
public final class Parra: Observable {
    // MARK: - Lifecycle

    init() {}

    /// For us in test suites to create a mock instance that won't run in a
    /// ``ParraApp`` which creates an injects the inner ``ParraInternal``
    /// instance.
    init(parraInternal: ParraInternal) {
        self.parraInternal = parraInternal
    }

    // MARK: - Public

    public private(set) lazy var feedback: ParraFeedback = parraInternal
        .feedback

    @Published public internal(set) var user: ParraUser?

    // MARK: - Internal

    /// Need a common instance that will never be nil to provide as an
    /// envrionment object. It wraps a nullable ``ParraInternal`` instance that
    /// will actually never be nil in the context of a ``ParraApp``.
    static let `default` = Parra()

    @usableFromInline var parraInternal: ParraInternal!
}
