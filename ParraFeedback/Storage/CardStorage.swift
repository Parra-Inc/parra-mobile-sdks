//
//  CardStorage.swift
//  Parra Core
//
//  Created by Michael MacCallum on 3/1/22.
//

import Foundation
import ParraCore

private let kCurrentCardsKey = "current_cards"

internal actor CardStorage: ItemStorage {
    internal typealias DataType = [ParraCardItem]
    internal let storageModule: ParraStorageModule<[ParraCardItem]>
    
    internal init(storageModule: ParraStorageModule<[ParraCardItem]>) {
        self.storageModule = storageModule
    }
    
    internal func setCards(cardItems: [ParraCardItem]) {
        Task {
            try await storageModule.write(name: kCurrentCardsKey, value: cardItems)
        }
    }
    
    internal func currentCards() async -> [ParraCardItem] {
        return await storageModule.read(name: kCurrentCardsKey) ?? []
    }
}
