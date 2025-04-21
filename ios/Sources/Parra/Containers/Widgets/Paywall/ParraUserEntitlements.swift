//
//  ParraUserEntitlements.swift
//  Parra
//
//  Created by Mick MacCallum on 11/12/24.
//

import Combine
import StoreKit
import SwiftUI

private let logger = ParraLogger(category: "Parra User Entitlements")

@Observable
public final class ParraUserEntitlements {
    // MARK: - Lifecycle

    public init(
        current: [ParraUserEntitlement] = []
    ) {
        self.current = current
        self.updates = newTransactionListenerTask()
    }

    deinit {
        // Cancel the update handling task when you deinitialize the class.
        updates?.cancel()
    }

    // MARK: - Public

    public static let shared = ParraUserEntitlements()

    /// A publisher that enables subscribing to changes to the `current`
    /// property. Use this to receive notifications when the user's entitlements
    /// are updates. You can also use an `.onChange()` modifier with `current`.
    public let currentPublisher = PassthroughSubject<
        [ParraUserEntitlement],
        Never
    >()

    public let purchaseCompletePublisher = PassthroughSubject<
        (StoreKit.Transaction, Error?),
        Never
    >()

    /// A list of the entitlements belonging to the currently logged in user.
    public internal(set) var current: [ParraUserEntitlement] = [] {
        didSet {
            Task { @MainActor in
                propagateChanges()
            }
        }
    }

    /// Returns the entitlement object for the provided key, if the current user
    /// has this entitlement
    @MainActor
    public func getEntitlement(
        for entitlementKey: String
    ) -> ParraUserEntitlement? {
        logger.debug("Getting entitlement for key", [
            "entitlementKey": entitlementKey
        ])

        guard let entitlement = current.first(where: { entitlement in
            return entitlement.key == entitlementKey
        }) else {
            return nil
        }

        guard entitlement.isConsumable else {
            logger.debug("Current user has non consumable entitlement", [
                "entitlementKey": entitlement.key,
                "entitlementId": entitlement.id
            ])

            return entitlement
        }

        guard let quantityAvailable = entitlement.quantityAvailable else {
            logger.warn(
                "Current user is missing quantity available data for consumable entitlement",
                [
                    "entitlementKey": entitlement.key
                ]
            )

            return nil
        }

        if quantityAvailable > 0 {
            logger.debug(
                "Current user has sufficient remaining quantity for consumable entitlement",
                [
                    "entitlementKey": entitlement.key,
                    "quantityAvailable": String(quantityAvailable)
                ]
            )

            return entitlement
        } else {
            logger.debug(
                "Current user has insufficient remaining quantity for consumable entitlement",
                [
                    "entitlementKey": entitlement.key,
                    "quantityAvailable": String(quantityAvailable)
                ]
            )

            return nil
        }
    }

    /// Whether the currently logged in user has, and in the case of consumable
    /// IAPs, has a non 0 quantity available.
    @MainActor
    public func isEntitled(
        to entitlementKey: String
    ) -> Bool {
        if let firstMatch = getEntitlement(for: entitlementKey) {
            logger.debug("Current user has entitlement", [
                "entitlementKey": entitlementKey,
                "isConsumable": String(firstMatch.isConsumable),
                "isFree": String(firstMatch.isFree),
                "quantityAvailable": String(firstMatch.quantityAvailable ?? -1),
                "quantityConsumed": String(firstMatch.quantityConsumed ?? -1)
            ])

            return true
        }

        logger.debug("Current user is missing entitlement", [
            "entitlement": entitlementKey
        ])

        return false
    }

    /// Whether the currently logged in user has the provided entitlement key.
    @MainActor
    public func hasEntitlement(
        for key: String
    ) -> Bool {
        let isEntitled = current.contains { entitlement in
            return entitlement.key == key
        }

        if isEntitled {
            logger.trace("Current user has entitlement", [
                "entitlement": key
            ])
        } else {
            logger.warn("Current user is missing entitlement", [
                "entitlement": key
            ])
        }

        return isEntitled
    }

    /// Whether the currently logged in user has the provided entitlement key.
    @MainActor
    public func hasEntitlement<Key>(
        for key: Key
    ) -> Bool where Key: RawRepresentable, Key.RawValue == String {
        return hasEntitlement(for: key.rawValue)
    }

    /// Whether the currently logged in user has the provided entitlement key.
    @MainActor
    public func hasEntitlement(
        _ entitlement: ParraEntitlement
    ) -> Bool {
        return hasEntitlement(for: entitlement.key)
    }

    /// Whether the currently logged in user has the provided entitlement key.
    /// If the entitlement is nil, this will return true.
    @MainActor
    public func hasEntitlement(
        _ entitlement: ParraEntitlement?
    ) -> Bool {
        guard let entitlement else {
            return true
        }

        return hasEntitlement(for: entitlement.key)
    }

    /// Fetches a paywall object associated with the provided entitlement and
    /// context string. The paywall object includes information about IAPs that
    /// should be presented in a paywall popup.
    @MainActor
    public func getPaywall(
        for entitlement: String,
        in context: String?
    ) async throws -> ParraAppPaywall {
        return try await Parra.default.parraInternal.api.getPaywall(
            for: entitlement,
            context: context
        )
    }

    /// Restores any purchases the user has made and associates them with the
    /// logged in user account.
    @MainActor
    public func restorePurchases() {
        logger.info("Restoring purchases")

        Task { @MainActor in
            let message: String
            do {
                try await reportCurrentEntitlements()

                message = "Purhases restored successfully."
            } catch let error as ParraError {
                message = error.description
            } catch {
                message = error.localizedDescription
            }

            let alert = UIAlertController(
                title: "Restore Purchases",
                message: message,
                preferredStyle: .alert
            )

            alert.addAction(
                UIAlertAction(
                    title: "Dismiss",
                    style: .default
                )
            )

            UIViewController.topMostViewController()?.present(
                alert,
                animated: true,
                completion: nil
            )
        }
    }

    // MARK: - Internal

    /// Retreives the latest entitlements for the user from the server and
    /// applies them.
    @MainActor
    func refreshEntitlements() async throws {
        logger.debug("Retreiving latest user entitlements")

        let entitlements = try await Parra.default.parraInternal.api.getUserEntitlements()

        updateEntitlements(entitlements)
    }

    /// Updates the entitlements to those provided.
    @MainActor
    func updateEntitlements(_ entitlements: [ParraUserEntitlement]) {
        if entitlements.isEmpty {
            logger.trace("Updating user entitlements (empty)")
        } else {
            let list = entitlements.map(\.key).joined(separator: ", ")

            logger.trace("Updating user entitlements", [
                "entitlements": "[\(list)]"
            ])
        }

        current = entitlements
    }

    /// Invoke this on logout before new user info is available to drop all the
    /// current user property state.
    @MainActor
    func reset() {
        logger.trace("Resetting user entitlements")

        current = []
    }

    @MainActor
    func propagateChanges() {
        Task { @MainActor in
            currentPublisher.send(current)
        }
    }

    // MARK: - Private

    private var updates: Task<Void, Never>?
    private var cancellables: Set<AnyCancellable> = []

    @MainActor
    private func reportCurrentEntitlements() async throws {
        logger.debug("Reporting current entitlements")

        var txReceipts: [String: (String, StoreKit.Transaction)] = [:]

        for await verificationResult in Transaction.currentEntitlements {
            switch verificationResult {
            case .verified(let tx):
                txReceipts[tx.productID] = (
                    verificationResult.jwsRepresentation,
                    tx
                )

            case .unverified(let tx, let error):
                logger.error("Skipping unverified transaction.", error, [
                    "transactionId": String(tx.id),
                    "productId": verificationResult.unsafePayloadValue.productID
                ])
            }
        }

        if txReceipts.isEmpty {
            throw ParraError.message("No purchases found to restore.")
        }

        logger.trace("Found \(txReceipts.count) entitlement(s) to report")

        let api = Parra.default.parraInternal.api

        do {
            let result = try await api.reportPurchases(
                with: txReceipts.values.map(\.0)
            )

            for (_, tx) in txReceipts.values {
                await finishTransaction(tx)
            }

            let productIds = txReceipts.keys.joined(separator: ", ")
            logger.debug("Purchase reported successfully", [
                "productIds": "[\(productIds)]"
            ])

            updateEntitlements(result.entitlements)
        } catch {
            for (_, tx) in txReceipts.values {
                await failTransaction(tx, with: error)
            }

            throw error
        }
    }

    private func newTransactionListenerTask() -> Task<Void, Never> {
        return Task(
            priority: .background
        ) { @MainActor in
            for await verificationResult in Transaction.updates {
                await self.handle(
                    updatedTransaction: verificationResult
                )
            }
        }
    }

    @MainActor
    private func handle(
        updatedTransaction verificationResult: VerificationResult<StoreKit.Transaction>
    ) async {
        switch verificationResult {
        case .unverified(let tx, let error):
            logger.error("Skipping handling unverified transaction", error, [
                "transactionId": String(tx.id),
                "productId": tx.productID
            ])
        case .verified(let tx):
            logger.debug("Handling verified transaction", [
                "transactionId": String(tx.id),
                "productId": tx.productID
            ])

            do {
                let api = Parra.default.parraInternal.api
                let result = try await api.reportPurchase(
                    with: verificationResult.jwsRepresentation
                )

                logger.debug("Purchase reported successfully", [
                    "productId": tx.productID,
                    "transactionId": String(tx.id)
                ])

                updateEntitlements(result.entitlements)
                await finishTransaction(tx)
            } catch {
                logger.error("Failed to report purchase", error, [
                    "productId": tx.productID
                ])

                await failTransaction(tx, with: error)
            }
        }
    }

    @MainActor
    private func finishTransaction(_ tx: StoreKit.Transaction) async {
        logger.trace("Finishing transaction", [
            "transactionId": String(tx.id),
            "productId": tx.productID
        ])

        await tx.finish()

        purchaseCompletePublisher.send((tx, nil))
    }

    @MainActor
    private func failTransaction(
        _ tx: StoreKit.Transaction,
        with error: Error
    ) async {
        logger.trace("Failed transaction", [
            "transactionId": String(tx.id),
            "productId": tx.productID
        ])

        purchaseCompletePublisher.send((tx, error))
    }
}
