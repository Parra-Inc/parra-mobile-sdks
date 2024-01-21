//
//  Parra+Notifications.swift
//  Parra
//
//  Created by Mick MacCallum on 4/3/22.
//

import Foundation

public extension Parra {
    
    /// A notification that is fired with the Parra module is about to begin syncrhonizing data with the Parra API. Each sync
    /// will include a unique token used to identify a given sync. This token is attached to the notification's `userInfo` with
    /// the key `Parra.Constant.syncTokenKey`.
    static let syncDidBeginNotification = NSNotification.Name("ParraSyncDidBeginNotification")
    
    /// A notification that is fired with the Parra module is about has completed syncrhonizing data with the Parra API. Each sync
    /// will include a unique token used to identify a given sync. This token is attached to the notification's `userInfo` with
    /// the key `Parra.Constant.syncTokenKey`.
    static let syncDidEndNotification = NSNotification.Name("ParraSyncDidEndNotification")

    /// A notification that is fired when the Parra theme is about to change. At this point, no UI elements have been updated to
    /// reflect the new theme.
    static let themeWillChangeNotification = NSNotification.Name("ParraThemeWillChangeNotification")

    /// A notification that is fired when the Parra theme has just changed. At this point, all Parra UI elements have been updated to
    /// reflect the new theme.
    static let themeDidChangeNotification = NSNotification.Name("ParraThemeDidChangeNotification")
}
