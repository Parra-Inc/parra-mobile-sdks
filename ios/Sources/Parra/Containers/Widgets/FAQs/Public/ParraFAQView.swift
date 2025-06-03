//
//  ParraFAQView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/3/24.
//

import SwiftUI

struct ParraFAQView: View {
    // MARK: - Internal

    var layout: ParraAppFaqLayout
    var config: ParraFAQConfiguration

    var body: some View {
        VStack(spacing: 0) {
            ParraMediaAwareScrollView {
                withContent(content: layout.description) { content in
                    componentFactory.buildLabel(
                        text: content,
                        localAttributes: ParraAttributes.Label(
                            text: ParraAttributes.Text(
                                style: .subheadline
                            ),
                            background: parraTheme.palette.primaryBackground
                                .toParraColor()
                        )
                    )
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding(.bottom, 16)
                }

                ForEach(
                    Array(layout.sections)
                ) { section in
                    FAQSectionView(section: section)
                }

                Spacer()
            }
            .emptyPlaceholder(layout.sections) {
                componentFactory.buildEmptyState(
                    config: .default,
                    content: config.emptyStateContent
                )
            }

            WidgetFooter { () -> ParraContainedButtonComponent? in
                guard let formStub = layout.feedbackForm else {
                    return nil
                }

                return componentFactory.buildContainedButton(
                    config: ParraTextButtonConfig(
                        type: .primary,
                        size: .large,
                        isMaxWidth: true
                    ),
                    content: .init(
                        text: ParraLabelContent(text: "Ask a question"),
                        isLoading: false
                    ),
                    localAttributes: ParraAttributes.ContainedButton(
                        normal: .init(
                            padding: .zero
                        )
                    ),
                    onPress: {
                        presentedForm = ParraFeedbackForm(
                            from: formStub
                        )
                    }
                )
            }
        }
        .safeAreaPadding(.horizontal)
        .background(
            parraTheme.palette.primaryBackground.toParraColor()
        )
        .navigationTitle(layout.title ?? "")
        .presentParraFeedbackFormWidget(
            with: $presentedForm
        )
    }

    // MARK: - Private

    @State private var presentedForm: ParraFeedbackForm?

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme
}
