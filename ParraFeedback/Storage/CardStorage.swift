//
//  CardStorage.swift
//  Parra Core
//
//  Created by Michael MacCallum on 3/1/22.
//

import Foundation
import ParraCore

private let kCurrentCardsKey = "current_cards"

actor CardStorage: ItemStorage {
    typealias DataType = [ParraCardItem]
    let storageModule: ParraStorageModule<[ParraCardItem]>
    
    init(storageModule: ParraStorageModule<[ParraCardItem]>) {
        self.storageModule = storageModule
    }
    
    func setCards(cardItems: [ParraCardItem]) {
        Task {
            try await storageModule.write(name: kCurrentCardsKey, value: cardItems)
        }
    }
    
    func currentCards() async -> [ParraCardItem] {
        return await storageModule.read(name: kCurrentCardsKey) ?? []
    }
}
