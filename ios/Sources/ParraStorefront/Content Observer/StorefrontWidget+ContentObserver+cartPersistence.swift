//
//  StorefrontWidget+ContentObserver+cartPersistence.swift
//  Parra
//
//  Created by Mick MacCallum on 10/8/24.
//

import Buy
import Foundation
import Parra

private let logger = ParraLogger()
private let DEFAULTS_CART_KEY = "parra_shopping_cart_state"

extension StorefrontWidget.ContentObserver {
    func readPersistedCart(
        for user: ParraUser?
    ) -> CartState.ReadyStateInfo? {
        let storageKey = createCartStorageKey(for: user)

        if let stored = UserDefaults.standard.string(
            forKey: storageKey
        ), let data = stored.data(
            using: .utf8
        ), let existingCart = try? JSONDecoder().decode(
            CartState.ReadyStateInfo.self,
            from: data
        ) {
            let lastWeek = Date().addingTimeInterval(-7 * 24 * 60 * 60)

            if existingCart.lastUpdated <= lastWeek {
                logger.info("Cart was more than a week old. Creating new one.")

                deletePersistedCart(for: user)

                return nil
            }

            return existingCart
        }

        return nil
    }

    func writePersistedCart(
        with readyStateInfo: CartState.ReadyStateInfo,
        as user: ParraUser?
    ) {
        if let data = try? JSONEncoder().encode(readyStateInfo), let jsonString = String(
            data: data,
            encoding: .utf8
        ) {
            logger.info("Persisting cart for current user")
            let storageKey = createCartStorageKey(for: user)

            UserDefaults.standard.set(jsonString, forKey: storageKey)
        }
    }

    func deletePersistedCart(
        for user: ParraUser?
    ) {
        let storageKey = createCartStorageKey(for: user)

        UserDefaults.standard.removeObject(
            forKey: storageKey
        )
    }

    private func createCartStorageKey(
        for user: ParraUser?
    ) -> String {
        let userId = user?.info.id ?? "guest"

        return "\(DEFAULTS_CART_KEY).\(userId)"
    }
}
