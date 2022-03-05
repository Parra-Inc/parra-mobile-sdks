//
//  CardStorage.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/1/22.
//

import Foundation

private let kCardsKey = "com.parrafeedback.cards.data"

class CardStorage: ItemStorage {
    let storageMedium: DataStorageMedium
    private var underlyingStorage = [CardItem]()
    
    required init(storageMedium: DataStorageMedium) {
        self.storageMedium = storageMedium
    }
    
    func loadData() async {
        // No op if storage medium is memory
    }
    
    func updateCards(cardItems: [CardItem]) {
        underlyingStorage = cardItems
    }
    
    func currentCards() -> [CardItem] {
        return underlyingStorage
    }
}
