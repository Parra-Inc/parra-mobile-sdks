//
//  CardStorage.swift
//  Parra Core
//
//  Created by Michael MacCallum on 3/1/22.
//

import Foundation
import ParraCore

internal actor CardStorage: ItemStorage {
    private enum Constant {
        static let currentCardsKey = "current_cards"
    }

    internal typealias DataType = [ParraCardItem]
    internal let storageModule: ParraStorageModule<[ParraCardItem]>
    
    internal init(storageModule: ParraStorageModule<[ParraCardItem]>) {
        self.storageModule = storageModule
    }
    
    internal func setCards(cardItems: [ParraCardItem]) {
        Task {
            try await storageModule.write(
                name: Constant.currentCardsKey,
                value: cardItems
            )
        }
    }
    
    internal func currentCards() async -> [ParraCardItem] {
        return await storageModule.read(
            name: Constant.currentCardsKey
        ) ?? []
    }
}
