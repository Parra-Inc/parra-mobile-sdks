//
//  ParraPaywalledContentView.swift
//  Parra
//
//  Created by Mick MacCallum on 11/11/24.
//

import StoreKit
import SwiftUI

// synchronously check user.entitlements
// need to observe user.entitlements changing

private let logger = Logger(category: "Parra Paywalled Content View")

public struct ParraPaywalledContentView<
    LockedContent,
    UnlockedContent
>: View where LockedContent: View, UnlockedContent: View {
    // MARK: - Lifecycle

    public init(
        entitlement: ParraEntitlement?,
        /// Additional information about where the paywall will be presented from
        context: String? = nil,
        config: ParraPaywallConfig? = nil,
        @ViewBuilder lockedContentBuilder: @escaping (
            _ entitlement: ParraEntitlement,
            _ unlock: @escaping () async throws -> Void
        ) -> LockedContent,
        @ViewBuilder unlockedContentBuilder: @escaping () -> UnlockedContent
    ) {
        self.entitlement = entitlement
        self.context = context
        self.config = if let config {
            config
        } else {
            if let entitlement {
                ParraPaywallConfig.defaultConfig(for: entitlement.key) ?? .default
            } else {
                .default
            }
        }
        self.lockedContentBuilder = lockedContentBuilder
        self.unlockedContentBuilder = unlockedContentBuilder
    }

    // MARK: - Public

    public enum LockedState {
        /// The default state used while the initial lock/unlocked state is
        /// still being determined.
        case initial

        case locked

        case unlocked
    }

    public let entitlement: ParraEntitlement?
    public let context: String?
    public let config: ParraPaywallConfig?

    /// The state used when the user doesn't have the required entitlement.
    /// Content should be hidden or obscured when in this state. Call the
    /// associated "unlock" function to trigger the presentation of
    /// the paywall configured for the provided entitlement in the Parra
    /// dashboard.
    public let lockedContentBuilder: (
        _ entitlement: ParraEntitlement,
        _ unlock: @escaping () async throws -> Void
    ) -> LockedContent
    public let unlockedContentBuilder: () -> UnlockedContent

    public var body: some View {
        content.onChange(
            of: userEntitlements.current,
            initial: true
        ) { _, _ in
            guard let entitlement else {
                lockedState = .unlocked

                return
            }

            if userEntitlements.hasEntitlement(entitlement) {
                lockedState = .unlocked
            } else {
                lockedState = .locked
            }
        }
        .presentParraPaywall(
            entitlement: entitlement?.key ?? "unknown",
            context: context,
            isPresented: $isShowingPaywall,
            config: config
        ) { _ in
            if let continuation {
                continuation.resume()

                self.continuation = nil
            }
        }
    }

    // MARK: - Private

    /// The state used when the user has the necessary entitlement to view
    /// the content. This is the normal rendering mode for the content.

    @Environment(\.parraUserEntitlements) private var userEntitlements

    @State private var lockedState: LockedState = .initial
    @State private var isShowingPaywall = false
    @State private var continuation: CheckedContinuation<Void, Never>?

    @ViewBuilder
    @MainActor private var content: some View {
        if let entitlement {
            switch lockedState {
            case .initial:
                // Won't trigger onAppear if this is just an EmptyView.
                ZStack {
                    EmptyView()
                }
            case .locked:
                lockedContentBuilder(entitlement, triggerUnlock)
            case .unlocked:
                unlockedContentBuilder()
            }
        } else {
            unlockedContentBuilder()
        }
    }

    @MainActor
    private func triggerUnlock() async throws {
        guard let entitlement else {
            lockedState = .unlocked

            return
        }

        guard !userEntitlements.hasEntitlement(entitlement) else {
            logger.info("Skipping unlock. User already has entitlement", [
                "entitlement": entitlement
            ])

            return
        }

        isShowingPaywall = true

        await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }
}

private struct TestContentView: View {
    // MARK: - Internal

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.purple, .yellow],
                startPoint: animateGradient ? .topLeading : .bottomLeading,
                endPoint: animateGradient ? .bottomTrailing : .topTrailing
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(
                    .linear(duration: 2.0)
                        .repeatForever(autoreverses: true)
                ) {
                    animateGradient.toggle()
                }
            }

            Text("Paid Content $$")
                .font(.title)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: 200
        )
    }

    // MARK: - Private

    @State private var animateGradient = false
}

#Preview {
    ParraAppPreview {
        VStack {
            ParraPaywalledContentView(
                entitlement: ParraEntitlement(
                    id: .uuid,
                    key: "test",
                    title: "something"
                ),
                context: "",
                lockedContentBuilder: { _, unlock in
                    ZStack {
                        Color.purple
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: 200
                            )

                        TestContentView()
                            .blur(radius: 10)

                        Button {
                            Task {
                                do {
                                    try await unlock()
                                } catch {
                                    print(
                                        "Failed to unlock! \(error.localizedDescription)"
                                    )
                                }
                            }
                        } label: {
                            Image(systemName: "lock")
                        }
                    }
                    .clipped()
                },
                unlockedContentBuilder: {
                    TestContentView()
                }
            )
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }
}
