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
struct SheetWithLoader<Data, SheetContent>: ViewModifier
    where SheetContent: View, Data: Equatable
{
    // MARK: - Lifecycle

    init(
        loadType: Binding<ViewDataLoader<Data, SheetContent>.LoadType?>,
        loader: ViewDataLoader<Data, SheetContent>,
        onDismiss: ((SheetDismissType) -> Void)?
    ) {
        self._loadType = loadType
        self.loader = loader
        self.onDismiss = onDismiss
    }

    // MARK: - Internal

    enum LoadState {
        // Initial state. Standing by and waiting for start signal
        case ready
        // Start signal received. In this state until complete or error
        case started
        case complete(Data)
        case error(Error)
    }

    @Environment(Parra.self) var parra

    // Externally controlled state to use to determine when to kick off
    // the loader and with what data
    @Binding var loadType: ViewDataLoader<Data, SheetContent>.LoadType?

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
                        loader.render(parra, data, dismiss)
                    }
                }
            )
            .presentationDetents([.large])
    }

    // MARK: - Private

    @State private var state: LoadState = .ready

    private let loader: ViewDataLoader<Data, SheetContent>
    private let onDismiss: ((SheetDismissType) -> Void)?

    @MainActor
    private func dismiss(_ type: SheetDismissType) {
        loadType = .none
        state = .ready

        onDismiss?(type)
    }

    private func initiateLoad(
        with type: ViewDataLoader<Data, SheetContent>.LoadType
    ) {
        Task {
            do {
                let result = try await loader.load(parra, type)

                await MainActor.run {
                    state = .complete(result)
                }
            } catch {
                await MainActor.run {
                    state = .error(error)
                }
            }
        }
    }
}
