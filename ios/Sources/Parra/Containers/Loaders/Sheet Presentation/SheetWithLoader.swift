//
//  SheetWithLoader.swift
//  Parra
//
//  Created by Mick MacCallum on 3/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

/// Facilitates loading data asynchonously then presenting a sheet with a view
/// rendered from the data.
@MainActor
struct SheetWithLoader<TransformParams, Data, SheetContent>: ViewModifier
    where SheetContent: View, Data: Equatable, TransformParams: Equatable
{
    // MARK: - Lifecycle

    init(
        loadType: Binding<
            ViewDataLoader<TransformParams, Data, SheetContent>
                .LoadType?
        >,
        loader: ViewDataLoader<TransformParams, Data, SheetContent>,
        detents: Set<PresentationDetent> = [.large],
        visibility: Visibility = .visible,
        onDismiss: ((ParraSheetDismissType) -> Void)?
    ) {
        self._loadType = loadType
        self.loader = loader
        self.detents = detents
        self.visibility = visibility
        self.onDismiss = onDismiss
    }

    // MARK: - Internal

    @Environment(\.parra) var parra

    // Externally controlled state to use to determine when to kick off
    // the loader and with what data
    @Binding var loadType: ViewDataLoader<TransformParams, Data, SheetContent>
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
                        SheetStateContainer {
                            return loader.render(parra, data, dismiss)
                        }
                        .presentationDetents(detents)
                        .presentationDragIndicator(visibility)
                    }
                }
            )
    }

    // MARK: - Private

    @State private var state: SheetLoadState<Data> = .ready

    private let loader: ViewDataLoader<TransformParams, Data, SheetContent>
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
        with type: ViewDataLoader<TransformParams, Data, SheetContent>.LoadType
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
            let result = try await transformer(parra, params)

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
