//
//  ParraFeedbackFormView.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 6/6/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import SwiftUI
import Combine



struct ParraFeedbackFormView: View {
    @StateObject var viewModel: FeedbackFormViewState

    var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(viewModel.title)
                .font(.largeTitle)
                .fontWeight(.bold)

            if let description = viewModel.description {
                Text(description)
                    .font(.subheadline).foregroundColor(.gray)
            }
        }
    }

    var fieldViews: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(viewModel.fields) { fieldWithState in
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
                case .feedbackFormInputFieldData(_):
                    // TODO: Support "input" type
                    EmptyView()
                }
            }
        }
    }

    var footer: some View {
        VStack(spacing: 16) {
            Button {
                viewModel.submit()
            } label: {
                Text("Submit")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(viewModel.canSubmit ? .accentColor : Color.gray)
                    .cornerRadius(8)
            }
            .disabled(!viewModel.canSubmit)

            Button {
                Parra.logEvent(.tap(element: "powered-by-parra"))

                UIApplication.shared.open(Parra.Constants.parraWebRoot)
            } label: {
                ParraLogo(type: .poweredBy)
            }
        }
    }

    var body: some View {
        NavigationView {
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
            .safeAreaPadding()
        }
    }

    private func onFieldValueChanged(field: FeedbackFormField, value: String?) {
        viewModel.onFieldValueChanged(
            field: field,
            value: value
        )
    }
}

struct ParraFeedbackFormView_Previews: PreviewProvider {
    static var previews: some View {
        let formData = FeedbackFormData(
            title: "Leave feedback",
            description: "We'd love to hear from you. Your input helps us make our product better.",
            fields: [
                .init(
                    name: "type",
                    title: "Type of Feedback",
                    helperText: nil,
                    type: .select,
                    required: true,
                    data: .feedbackFormSelectFieldData(
                        .init(
                            placeholder: "Please select an option",
                            options: [
                                .init(title: "General feedback", value: "general", isOther: nil),
                                .init(title: "Bug report", value: "bug", isOther: nil),
                                .init(title: "Feature request", value: "feature", isOther: nil),
                                .init(title: "Idea", value: "idea", isOther: nil),
                                .init(title: "Other", value: "other", isOther: nil),
                            ]
                        )
                    )
                ),
                .init(
                    name: "response",
                    title: "Your Feedback",
                    helperText: nil,
                    type: .text,
                    required: true,
                    data: .feedbackFormTextFieldData(
                        .init(
                            placeholder: "Enter your feedback here...",
                            lines: nil,
                            maxLines: 3,
                            minCharacters: 12,
                            maxCharacters: 69,
                            maxHeight: nil
                        )
                    )
                )
            ]
        )

        return VStack {
            ParraFeedbackFormView(
                viewModel: FeedbackFormViewState(
                    formData: formData,
                    config: .default
                )
            )
        }
    }
}
