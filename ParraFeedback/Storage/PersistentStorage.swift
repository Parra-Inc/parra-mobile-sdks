//
//  ItemStorage.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 2/28/22.
//

import Foundation

protocol ItemStorage {
    init(storageMedium: DataStorageMedium)
    
    func loadData() async
}
