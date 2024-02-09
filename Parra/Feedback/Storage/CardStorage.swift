//
//  CardStorage.swift
//  Parra
//
//  Created by Michael MacCallum on 3/1/22.
//

import Foundation

actor CardStorage: ItemStorage {
    // MARK: - Lifecycle

    init(storageModule: ParraStorageModule<[ParraCardItem]>) {
        self.storageModule = storageModule
    }

    // MARK: - Internal

    typealias DataType = [ParraCardItem]

    let storageModule: ParraStorageModule<[ParraCardItem]>

    func setCards(cardItems: [ParraCardItem]) {
        Task {
            try await storageModule.write(
                name: Constant.currentCardsKey,
                value: cardItems
            )
        }
    }

    func currentCards() async -> [ParraCardItem] {
        return await storageModule.read(
            name: Constant.currentCardsKey
        ) ?? []
    }

    // MARK: - Private

    private enum Constant {
        static let currentCardsKey = "current_cards"
    }
}
