//
//  CardStorage.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/1/22.
//

import Foundation

actor CardStorage: PersistentStorage {
    let storageMedium: DataStorageMedium
    
    init(storageMedium: DataStorageMedium) {
        self.storageMedium = storageMedium
    }
    
    func loadData() async {
        // no op
    }
    
//    func getCards() -> [CardItem] {
//        
//    }
}
