//
//  SessionStorage.swift
//  ParraCore
//
//  Created by Mick MacCallum on 11/20/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

// 1. Start session
// 2. Write event to session
// 3. End session
// 4. Retreive all sessions

internal actor SessionStorage: ItemStorage {
//    internal enum Key {
//        static let currentUser = "current_user_credential"
//    }

    typealias DataType = ParraCredential

    let storageModule: ParraStorageModule<ParraCredential>

    init(storageModule: ParraStorageModule<ParraCredential>) {
        self.storageModule = storageModule
    }

//    func updateCredential(credential: ParraCredential?) async {
//        try? await storageModule.write(name: Key.currentUser, value: credential)
//    }
//
//    func currentCredential() async -> ParraCredential? {
//        return await storageModule.read(name: Key.currentUser)
//    }

    func start(session: ParraSession) {

    }

    func write(event: ParraSessionEvent, to session: ParraSession) {

    }
}
