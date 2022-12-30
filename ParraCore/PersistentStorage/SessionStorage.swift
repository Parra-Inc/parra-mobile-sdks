//
//  SessionStorage.swift
//  ParraCore
//
//  Created by Mick MacCallum on 11/20/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

internal actor SessionStorage: ItemStorage {
    typealias DataType = ParraSession

    let storageModule: ParraStorageModule<ParraSession>

    init(storageModule: ParraStorageModule<ParraSession>) {
        self.storageModule = storageModule
    }

    func update(session: ParraSession) async {
        try? await storageModule.write(
            name: String(session.createdAt.timeIntervalSince1970),
            value: session
        )
    }

    func start(session: ParraSession) {
//        storageModule.write(name: <#T##String#>, value: <#T##ParraSession?#>)
    }

    func write(event: ParraSessionEvent, to session: ParraSession) {

    }
}
