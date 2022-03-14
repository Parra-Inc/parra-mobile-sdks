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
    typealias DataType = [CardItem]
    let storageModule: ParraStorageModule<[CardItem]>
    
    init(storageModule: ParraStorageModule<[CardItem]>) {
        self.storageModule = storageModule
    }
    
    func setCards(cardItems: [CardItem]) {
        Task {
            try await storageModule.write(name: kCurrentCardsKey, value: cardItems)
        }
    }
    
    func currentCards() async -> [CardItem] {
        return await storageModule.read(name: kCurrentCardsKey) ?? []
    }
}
