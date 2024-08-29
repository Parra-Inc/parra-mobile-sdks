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
public final class Parra: Observable, Equatable {
    // MARK: - Lifecycle

    private init() {}

    /// For use in test suites to create a mock instance that won't run in a
    /// ``ParraApp`` which creates an injects the inner ``ParraInternal``
    /// instance.
    init(parraInternal: ParraInternal) {
        self.parraInternal = parraInternal
    }

    // MARK: - Public

    public private(set) lazy var feedback: ParraFeedback = parraInternal
        .feedback

    public private(set) lazy var releases: ParraReleases = parraInternal
        .releases

    public private(set) lazy var auth: ParraAuth = .init(
        parraInternal: parraInternal
    )

    /// An object representing the currently logged in user, if one exists.
    /// This is only relevant to Parra Auth.
    public private(set) lazy var user: ParraUserManager = .init(
        parraInternal: parraInternal
    )

    public static func == (lhs: Parra, rhs: Parra) -> Bool {
        // References changing here should never cause re-renders.
        return true
    }

    // MARK: - Internal

    /// Need a common instance that will never be nil to provide as an
    /// envrionment object. It wraps a nullable ``ParraInternal`` instance that
    /// will actually never be nil in the context of a ``ParraApp``.
    static let `default` = Parra()

    @usableFromInline var parraInternal: ParraInternal!
}
