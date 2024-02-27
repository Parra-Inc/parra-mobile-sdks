//
//  FeedbackFormLoader.swift
//  Parra
//
//  Created by Mick MacCallum on 2/12/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger(category: "Feedback form loader")

@MainActor
struct FeedbackFormLoader: ViewModifier {
    // MARK: - Lifecycle

    init(
        initialState: Binding<FormState>,
        localFactory: FeedbackFormWidget.Factory? = nil,
        onDismiss: ((FeedbackFormDismissType) -> Void)? = nil
    ) {
        self.localFactory = localFactory
        self.onDismiss = onDismiss

        _initialState = initialState
        _formState = State(initialValue: initialState.wrappedValue)
    }

    // MARK: - Internal

    enum FormState: Equatable {
        case initial
        case formId(String)
        case loading
        case form(ParraFeedbackFormResponse)
        case error(String)
    }

    @Environment(Parra.self) var parra
    @Binding var initialState: FormState

    var localFactory: FeedbackFormWidget.Factory? = nil
    var onDismiss: ((FeedbackFormDismissType) -> Void)? = nil

    func body(content: Content) -> some View {
        content
            .onAppear(perform: {
                hasSubmitted = false
            })
            .onChange(of: initialState) { _, newValue in
                formState = newValue
            }
            .onChange(of: formState) { oldValue, newValue in
                switch (oldValue, newValue) {
                case (_, .form):
                    isPresented = true
                case (_, .formId(let formId)):
                    formState = .loading

                    loadForm(with: formId)
                case (_, .initial):
                    isPresented = false
                case (_, .loading):
                    break
                case (_, .error):
                    break
                }
            }
            .sheet(
                isPresented: $isPresented,
                onDismiss: {
                    // Reset the binding that was used to seed the state so that
                    // the call site can receive the state reset.
                    initialState = .initial
                    formState = .initial

                    onDismiss?(hasSubmitted ? .submitted : .cancelled)
                },
                content: {
                    if let widget = createFormWidget() {
                        widget
                    } else {
                        EmptyView()
                    }
                }
            )
            .presentationDetents([.large])
    }

    // MARK: - Private

    @State private var formState: FormState

    @State private var hasSubmitted = false

    @State private var isPresented = false

    private func loadForm(with id: String) {
        func updateState(to state: FormState) async {
            await MainActor.run {
                $formState.wrappedValue = state
            }
        }

        Task {
            do {
                let form = try await parra.feedback.fetchFeedbackForm(
                    formId: id
                )

                await updateState(to: .form(form))
            } catch {
                await updateState(to: .error(error.localizedDescription))
            }
        }
    }

    private func createFormWidget()
        -> FeedbackFormWidget?
    {
        guard case .form(let form) = formState else {
            return nil
        }

        let theme = parra.configuration.theme
        let globalComponentAttributes = parra.configuration
            .globalComponentAttributes

        let componentFactory = ComponentFactory(
            local: localFactory,
            global: globalComponentAttributes,
            theme: theme
        )

        let contentObserver = FeedbackFormWidget.ContentObserver(
            formData: form.data
        )

        contentObserver.submissionHandler = { data in
            logger.info("Submitting feedback form data")

            parra.logEvent(.submit(form: "feedback_form"), [
                "formId": form.id
            ])

            hasSubmitted = true
            formState = .initial

            Task {
                do {
                    try await parra.networkManager.submitFeedbackForm(
                        with: form.id,
                        data: data
                    )
                } catch {
                    logger.error(
                        "Error submitting feedback form: \(form.id)",
                        error
                    )
                }
            }
        }

        let style = FeedbackFormWidget.Style.default(with: theme)

        return FeedbackFormWidget(
            componentFactory: componentFactory,
            contentObserver: contentObserver,
            config: .default,
            style: style
        )
    }
}
