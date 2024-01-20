//
//  ParraLogContext.swift
//  Parra
//
//  Created by Mick MacCallum on 9/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

/// A context object representative of a log itself.
internal struct ParraLogContext {
    /// Context around where the actual log came from.
    internal let callSiteContext: ParraLoggerCallSiteContext

    /// Context related to the logger that the log was made with.
    ///
    /// It is possible that the context for a give log is missing the context of the logger that generated
    /// the log. For example, in cases where static logger methods are used.
    internal let loggerContext: ParraLoggerContext?

    /// Whether or not this log should be forced to bypass normal rules for when it should be
    /// processed as a log that is output through the console vs. being written as an event.
    /// This is for internal use only, and only in cases where creating events in response to the
    /// creation of a log is a recursive operation. Like failures within the session storage modules.
    internal let bypassEventCreation: Bool
}
