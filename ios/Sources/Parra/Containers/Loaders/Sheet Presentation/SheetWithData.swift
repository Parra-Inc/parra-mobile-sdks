//
//  SheetWithData.swift
//  Parra
//
//  Created by Mick MacCallum on 2/25/25.
//

import SwiftUI

private let logger = Logger()

/// Facilitates loading data asynchonously then presenting a sheet with a view
/// rendered from the data.
@MainActor
struct SheetWithData<Data, Container>: ViewModifier
    where Data: Equatable, Container: ParraContainer
{
    // MARK: - Lifecycle

    init(
        data: Binding<Data?>,
        config: Container.Config,
        @ViewBuilder with renderer: @MainActor @escaping (
            _ config: Container.Config,
            _ parra: Parra,
            _ data: Data,
            _ navigationPath: Binding<NavigationPath>,
            _ dismisser: ParraSheetDismisser?
        ) -> Container,
        detents: Set<PresentationDetent> = [],
        visibility: Visibility = .automatic,
        onDismiss: ((ParraSheetDismissType) -> Void)?
    ) {
        self._data = data
        self.config = config
        self.renderer = renderer
        self.detents = detents
        self.visibility = visibility
        self.onDismiss = onDismiss
    }

    // MARK: - Internal

    func body(content: Content) -> some View {
        content
            .sheet(
                isPresented: .init(
                    get: {
                        return data != nil
                    },
                    set: { newValue in
                        if !newValue {
                            data = nil
                        }
                    }
                ),
                onDismiss: {
                    dismiss(.cancelled)
                },
                content: {
                    if let data {
                        NavigationStack(path: $navigationState.navigationPath) {
                            renderer(
                                config,
                                Parra.default,
                                data,
                                $navigationState.navigationPath,
                                dismiss
                            )
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

    private var config: Container.Config

    @ViewBuilder private var renderer: @MainActor (
        _ config: Container.Config,
        _ parra: Parra,
        _ data: Data,
        _ navigationPath: Binding<NavigationPath>,
        _ dismisser: ParraSheetDismisser?
    ) -> Container

    // Externally controlled state to use to determine when to kick off
    // the loader and with what data
    @Binding private var data: Data?

    @State private var navigationState = NavigationState()

    private let detents: Set<PresentationDetent>
    private let visibility: Visibility
    private let onDismiss: ((ParraSheetDismissType) -> Void)?

    @MainActor
    private func dismiss(_ type: ParraSheetDismissType) {
        onDismiss?(type)
    }
}
