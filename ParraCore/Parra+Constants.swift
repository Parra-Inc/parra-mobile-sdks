//
//  Parra+Constants.swift
//  Parra Core
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation
import UIKit

public extension Parra {
    enum Constant {
        /// A key that cooresponds to a unique sync token provided with sync begin/ending notifications.
        public static let syncTokenKey = "syncToken"
        
        public static let brandColor = UIColor(
            red: 232.0 / 255.0,
            green: 68.0 / 255.0,
            blue: 71.0 / 255.0,
            alpha: 1.0
        )
        
        public static let parraWebRoot = URL(string: "https://parra.io/")!
        internal static let parraApiRoot = URL(string: "https://api.parra.io/v1/")!

        internal static let backgroundTaskName = "com.parra.session.backgroundtask"
        internal static let backgroundTaskDuration: TimeInterval = 25.0
    }
}
