//
//  CharacterSet+allowedUrlChars.swift
//  Parra
//
//  Created by Mick MacCallum on 7/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension CharacterSet {
    /// CharacterSet.urlHostAllowed and CharacterSet.urlQueryAllowed both allow
    /// the "+" symbol for some unfortunate reason.
    /// See https://datatracker.ietf.org/doc/html/rfc3986#section-2.3 for
    /// allowed chars definition.
    static let rfc3986Unreserved = CharacterSet(
        charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
    )
}
