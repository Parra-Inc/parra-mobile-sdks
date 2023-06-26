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
    @State var formId: String
    @State var data: FeedbackFormData
    @State var config: ParraCardViewConfig
    @State var onSubmit: ([FeedbackFormField: String]) -> Void

    /// Maps form field names to their current values and whether they're currently considered valid.
    @State private var formState = [String: (String, Bool)]()

    private var formFieldValues: [FeedbackFormField: String] {
        return data.fields.reduce([FeedbackFormField: String]()) { partialResult, next in
            guard let (value, _) = formState[next.name] else {
                return partialResult
            }

            var accumulator = partialResult
            accumulator[next] = value
            return accumulator
        }
    }

    // Submit enabled -> is the data for every field where "required" is set valid?
    private var canSubmit: Bool {
        return data.fields.reduce(true) { accumulator, field in
            let required = field.required ?? false

            // Don't count fields that aren't required.
            guard required else {
                return accumulator
            }

            guard let (_, valid) = formState[field.name] else {
                if required {
                    return false
                }

                return accumulator
            }

            return accumulator && valid
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text(data.title)
                    .font(.largeTitle)

                if let description = data.description {
                    Text(description)
                        .font(.subheadline).foregroundColor(.gray)
                }
            }

            ForEach(data.fields) { (field: FeedbackFormField) in
                switch field.data {
                case .feedbackFormSelectFieldData(let data):
                    ParraFeedbackFormSelectFieldView(
                        formId: formId,
                        field: field,
                        fieldData: data,
                        onFieldDataChanged: self.onFieldDataChanged
                    )
                case .feedbackFormTextFieldData(let data):
                    ParraFeedbackFormTextFieldView(
                        formId: formId,
                        field: field,
                        fieldData: data,
                        onFieldDataChanged: self.onFieldDataChanged
                    )
                case .feedbackFormInputFieldData(_):
                    // TODO: Support "input" type
                    EmptyView()
                }
            }

            Spacer()

            Button {
                onSubmit(formFieldValues)
            } label: {
                Text("Submit")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(canSubmit ? Color.blue : Color.gray)
                    .cornerRadius(8)
            }
            .disabled(!canSubmit)

            Button {
                Parra.logEvent(.tap(element: "powered-by-parra"))

                UIApplication.shared.open(Parra.Constants.parraWebRoot)
            } label: {
                Text(AttributedString(NSAttributedString.poweredByParra, including: \.uiKit))
                    .foregroundColor(config.backgroundColor.isLight()
                                     ? .black.opacity(0.1)
                                     : .white.opacity(0.2))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(EdgeInsets(top: 24, leading: 16, bottom: 24, trailing: 16))
    }

    private func onFieldDataChanged(_ name: String, _ value: String?, _ valid: Bool) {
        if let value {
            formState[name] = (value, valid)
        } else {
            formState.removeValue(forKey: name)
        }
    }
}

struct ParraFeedbackFormView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ParraFeedbackFormView(
                formId: "a",
                data: FeedbackFormData(
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
                ),
                config: ParraCardViewConfig.default,
                onSubmit: { _ in }
            )
        }
    }
}
