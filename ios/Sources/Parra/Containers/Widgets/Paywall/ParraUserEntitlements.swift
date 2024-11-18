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

    init() {
        self.updates = newTransactionListenerTask()
    }

    deinit {
        // Cancel the update handling task when you deinitialize the class.
        updates?.cancel()
    }

    // MARK: - Public

    /// A publisher that enables subscribing to changes to the `current`
    /// property. Use this to receive notifications when the user's entitlements
    /// are updates. You can also use an `.onChange()` modifier with `current`.
    public let currentPublisher = PassthroughSubject<
        [ParraUserEntitlement],
        Never
    >()

    public let purchaseCompletePublisher = PassthroughSubject<
        StoreKit.Transaction,
        Never
    >()

    /// A list of the entitlements belonging to the currently logged in user.
    public internal(set) var current: [ParraUserEntitlement] = [] {
        didSet {
            keyedEntitlements = current.reduce(into: [:]) { $0[$1.key] = $1 }

            propagateChanges()
        }
    }

    /// Whether the currently logged in user has the provided entitlement key.
    @MainActor
    public func hasEntitlement(
        for key: String
    ) -> Bool {
        let isEntitled = keyedEntitlements[key] != nil

        if isEntitled {
            logger.debug("Current user has entitlement", [
                "entitlement": key
            ])
        } else {
            logger.debug("Current user is missing entitlement", [
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

    /// Fetches a paywall object associated with the provided entitlement and
    /// context string. The paywall object includes information about IAPs that
    /// should be presented in a paywall popup.
    @MainActor
    public func getPaywall(
        for entitlement: String,
        in context: String?
    ) async throws -> ParraApplePaywall {
        return try await Parra.default.parraInternal.api.getPaywall(
            for: entitlement,
            context: context
        )
    }

    /// Restores any purchases the user has made and associates them with the
    /// logged in user account.
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

    static let shared = ParraUserEntitlements()

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

    func propagateChanges() {
        Task { @MainActor in
            currentPublisher.send(current)
        }
    }

    // MARK: - Private

    private var keyedEntitlements: [String: ParraUserEntitlement] = [:]

    private var updates: Task<Void, Never>?
    private var cancellables: Set<AnyCancellable> = []

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

        let api = await Parra.default.parraInternal.api
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

        await updateEntitlements(result.entitlements)
    }

    private func newTransactionListenerTask() -> Task<Void, Never> {
        return Task(
            priority: .background
        ) {
            for await verificationResult in Transaction.updates {
                await self.handle(
                    updatedTransaction: verificationResult
                )
            }
        }
    }

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
                let api = await Parra.default.parraInternal.api
                let result = try await api.reportPurchase(
                    with: verificationResult.jwsRepresentation
                )

                logger.debug("Purchase reported successfully", [
                    "productId": tx.productID,
                    "transactionId": String(tx.id)
                ])

                await updateEntitlements(result.entitlements)
                await finishTransaction(tx)
            } catch {
                logger.error("Failed to report purchase", error, [
                    "productId": tx.productID
                ])
            }
        }
    }

    private func finishTransaction(_ tx: StoreKit.Transaction) async {
        logger.trace("Finishing transaction", [
            "transactionId": String(tx.id),
            "productId": tx.productID
        ])

        await tx.finish()

        Task { @MainActor in
            purchaseCompletePublisher.send(tx)
        }
    }
}
