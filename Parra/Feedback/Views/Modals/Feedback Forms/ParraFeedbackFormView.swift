//
//  ParraFeedbackFormView.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 6/6/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import SwiftUI
import Combine

struct ParraFeedbackFormView: View, ParraWidget {
    typealias WidgetConfiguration = ParraFeedbackFormWidgetConfig

    @StateObject var state: FeedbackFormViewState
    @StateObject var configObserver: ParraWidgetConfigurationObserver<WidgetConfiguration>
    @StateObject var themeObserver: ParraThemeObserver

    var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            themeObserver.theme.buildLabelView(
                text: state.title,
                localConfig: configObserver.configuration.title
            )

            if let description = state.description {
                themeObserver.theme.buildLabelView(
                    text: description,
                    localConfig: configObserver.configuration.description
                )
            }
        }
    }

    var fieldViews: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(state.fields) { fieldWithState in
                let field = fieldWithState.field

                switch field.data {
                case .feedbackFormSelectFieldData(let data):
                    ParraFeedbackFormSelectFieldView(
                        fieldWithState: fieldWithState,
                        fieldData: .init(data: data),
                        onFieldValueChanged: self.onFieldValueChanged
                    )
                case .feedbackFormTextFieldData(let data):
                    ParraFeedbackFormTextFieldView(
                        fieldWithState: fieldWithState,
                        fieldData: .init(data: data),
                        onFieldValueChanged: self.onFieldValueChanged
                    )
                }
            }
        }
    }

    var footer: some View {
        VStack(alignment: .center, spacing: 16) {
            themeObserver.theme.buildButtonView(
                labelFactory: { statefulConfig in
                    themeObserver.theme.buildLabelView(
                        text: "Submit",
                        localConfig: statefulConfig
                    )
                },
                style: .primary,
                size: .large,
                variant: .contained,
                localConfig: configObserver.configuration.submitButton
            )
            .disabled(!state.canSubmit)

            ParraLogoButton(type: .poweredBy)
        }
        .frame(maxWidth: .infinity)
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 20) {
                header

                fieldViews
            }
            .layoutPriority(100)

            Spacer()
                .layoutPriority(0)

            footer
        }
        .background(themeObserver.theme.palette.primaryBackground)
        .safeAreaPadding()
        .environmentObject(configObserver)
        .environmentObject(themeObserver)
    }

    private func onFieldValueChanged(
        field: FeedbackFormField,
        value: String?
    ) {
        state.onFieldValueChanged(
            field: field,
            value: value
        )
    }
}

#Preview {
    FeedbackFormViewState.renderValidStates { formViewState in
        ParraFeedbackFormView(
            state: formViewState,
            configObserver: .init(
                configuration: .init(
                    title: nil,
                    description: nil,
                    selectFields: nil,
                    textFields: nil,
                    submitButton: nil
                )
            ),
            themeObserver: .init(
                theme: .default,
                notificationCenter: ParraNotificationCenter()
            )
        )
    }
}
