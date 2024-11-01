//
//  ParraUser.swift
//  Parra
//
//  Created by Mick MacCallum on 4/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// ! Important: Changing keys will result in user logouts when the persisted
//              info/credential objects are unable to be parsed on app launch.
public struct ParraUser: Equatable, Codable, Hashable {
    // MARK: - Lifecycle

    init(
        credential: Credential,
        info: Info
    ) {
        self.credential = credential
        self.info = info
    }

    // MARK: - Public

    public internal(set) var credential: Credential
    public internal(set) var info: Info
}
