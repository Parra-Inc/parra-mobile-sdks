//
//  SheetWithLoader.swift
//  Parra
//
//  Created by Mick MacCallum on 3/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public enum ParraSheetPresentationState: Equatable {
    case ready
    case loading
    case presented
}

/// Facilitates loading data asynchonously then presenting a sheet with a view
/// rendered from the data.
@MainActor
struct SheetWithLoader<TransformParams, Data, SheetContent>: ViewModifier
    where SheetContent: View, Data: Equatable, TransformParams: Equatable
{
    // MARK: - Lifecycle

    init(
        name: String,
        presentationState: Binding<ParraSheetPresentationState>,
        transformParams: TransformParams,
        transformer: @escaping ParraViewDataLoader<TransformParams, Data, SheetContent>
            .Transformer,
        loader: ParraViewDataLoader<TransformParams, Data, SheetContent>,
        detents: Set<PresentationDetent> = [],
        visibility: Visibility = .automatic,
        showDismissButton: Bool,
        onDismiss: ((ParraSheetDismissType) -> Void)?
    ) {
        self.name = name
        self._presentationState = presentationState
        self.transformParams = transformParams
        self.transformer = transformer
        self.loader = loader
        self.detents = detents
        self.visibility = visibility
        self.showDismissButton = showDismissButton
        self.onDismiss = onDismiss
        self.logger = Logger(category: "SheetWithLoader \(name)")
    }

    // MARK: - Internal

    func body(content: Content) -> some View {
        content
            .onChange(
                of: presentationState
            ) { oldValue, newValue in

                logger.debug("presentation state changed", [
                    "to": "\(newValue)",
                    "from": "\(oldValue)"
                ])

                if newValue == .loading {
                    Task { @MainActor in
                        await triggerTransform(
                            with: transformParams,
                            via: transformer
                        )
                    }
                }
            }
            .sheet(
                isPresented: .init(
                    get: {
                        return presentationState == .presented
                    },
                    set: { newValue in
                        if !newValue {
                            logger.debug("dismissing")

                            presentationState = .ready
                        }
                    }
                ),
                onDismiss: {
                    dismiss(.cancelled)
                },
                content: {
                    if let data {
                        NavigationStack(path: $navigationState.navigationPath) {
                            loader.render(
                                Parra.default,
                                data,
                                $navigationState.navigationPath,
                                dismiss
                            )
                            .if(showDismissButton && detents.isEmpty) { ctx in
                                ctx.toolbar {
                                    ToolbarItem(placement: .topBarTrailing) {
                                        ParraDismissButton()
                                    }
                                }
                            }
                        }
                        .environment(navigationState)
                        .presentationDetents(detents)
                        .presentationDragIndicator(
                            visibility == .automatic ? (
                                detents.isEmpty ? .hidden : .visible
                            ) : visibility
                        )
                    }
                }
            )
    }

    // MARK: - Private

    // Externally controlled state to use to determine when to kick off
    // the loader and with what data
    @Binding private var presentationState: ParraSheetPresentationState

    @Environment(\.parraAlertManager) private var alertManager

    @State private var data: Data?
    @State private var navigationState = NavigationState()

    private let name: String
    private let transformParams: TransformParams
    private let transformer: ParraViewDataLoader<TransformParams, Data, SheetContent>
        .Transformer
    private let loader: ParraViewDataLoader<TransformParams, Data, SheetContent>
    private let detents: Set<PresentationDetent>
    private let visibility: Visibility
    private let showDismissButton: Bool
    private let onDismiss: ((ParraSheetDismissType) -> Void)?

    private let logger: Logger

    @MainActor
    private func dismiss(_ type: ParraSheetDismissType) {
        onDismiss?(type)
        presentationState = .ready
    }

    private func triggerTransform(
        with params: TransformParams,
        via transformer: (Parra, TransformParams) async throws -> Data
    ) async {
        do {
            let result = try await transformer(Parra.default, params)

            await MainActor.run {
                data = result
                presentationState = .presented
            }
        } catch {
            logger.error(
                "Error preparing data for Parra sheet presentation.",
                error
            )

            alertManager.showErrorToast(
                title: "Something went wrong",
                userFacingMessage: "Please try again. Let us know if you keep experiencing this issue.",
                underlyingError: error
            )

            await MainActor.run {
                dismiss(.failed(error.localizedDescription))
            }
        }
    }
}
