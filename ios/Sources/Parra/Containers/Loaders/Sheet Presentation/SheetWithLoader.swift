//
//  SheetWithLoader.swift
//  Parra
//
//  Created by Mick MacCallum on 3/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// Important: !!! Do NOT use environment values in this file without being very
// careful that they do not trigger complete deinit and rebuild of sheets when
// things like auth or other global state changes.

/// Facilitates loading data asynchonously then presenting a sheet with a view
/// rendered from the data.
@MainActor
struct SheetWithLoader<TransformParams, Data, SheetContent>: ViewModifier
    where SheetContent: View, Data: Equatable, TransformParams: Equatable
{
    // MARK: - Lifecycle

    init(
        loadType: Binding<
            ParraViewDataLoader<TransformParams, Data, SheetContent>
                .LoadType?
        >,
        loader: ParraViewDataLoader<TransformParams, Data, SheetContent>,
        detents: Set<PresentationDetent> = [],
        visibility: Visibility = .automatic,
        onDismiss: ((ParraSheetDismissType) -> Void)?
    ) {
        self._loadType = loadType
        self.loader = loader
        self.detents = detents
        self.visibility = visibility
        self.onDismiss = onDismiss
    }

    // MARK: - Internal

    // Externally controlled state to use to determine when to kick off
    // the loader and with what data
    @Binding var loadType: ParraViewDataLoader<TransformParams, Data, SheetContent>
        .LoadType?

    func body(content: Content) -> some View {
        content
            .onChange(
                of: loadType,
                initial: true, { _, newValue in
                    guard let newValue else {
                        return
                    }

                    switch state {
                    case .ready:
                        initiateLoad(with: newValue)
                    case .started, .complete, .error:
                        break
                    }
                }
            )
            .sheet(
                isPresented: .init(
                    get: {
                        switch state {
                        case .ready, .error, .started:
                            return false
                        case .complete:
                            return true
                        }
                    },
                    set: { newValue in
                        if !newValue {
                            state = .ready
                        }
                    }
                ),
                onDismiss: {
                    dismiss(.cancelled)
                },
                content: {
                    if case .complete(let data) = state {
                        NavigationStack(path: $navigationState.navigationPath) {
                            loader.render(Parra.default, data, dismiss)
                                .if(detents.isEmpty) { ctx in
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

    @State private var state: SheetLoadState<Data> = .ready
    @State private var navigationState = NavigationState()

    private let loader: ParraViewDataLoader<TransformParams, Data, SheetContent>
    private let detents: Set<PresentationDetent>
    private let visibility: Visibility
    private let onDismiss: ((ParraSheetDismissType) -> Void)?

    @MainActor
    private func dismiss(_ type: ParraSheetDismissType) {
        loadType = .none
        state = .ready

        onDismiss?(type)
    }

    private func initiateLoad(
        with type: ParraViewDataLoader<TransformParams, Data, SheetContent>.LoadType
    ) {
        switch type {
        case .transform(let transformParams, let transformer):
            Task {
                await triggerTransform(
                    with: transformParams,
                    via: transformer
                )
            }
        case .raw(let data):
            state = .complete(data)
        }
    }

    private func triggerTransform(
        with params: TransformParams,
        via transformer: (Parra, TransformParams) async throws -> Data
    ) async {
        do {
            let result = try await transformer(Parra.default, params)

            await MainActor.run {
                state = .complete(result)
            }
        } catch {
            Logger.error(
                "Error preparing data for Parra sheet presentation.",
                error
            )

            await MainActor.run {
                state = .error(error)
                dismiss(.failed(error.localizedDescription))
            }
        }
    }
}
