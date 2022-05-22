//
//  Parra+Constants.swift
//  Parra Core
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation

public extension Parra {
    enum Constant {
        /// A key that cooresponds to a unique sync token provided with sync begin/ending notifications.
        public static let syncTokenKey = "syncToken"
        
        internal static let parraLogPrefix = "[PARRA]"
        
        internal static let parraApiRoot = URL(string: "https://api.parra.io/v1/")!
    }
}
