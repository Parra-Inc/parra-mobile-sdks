//
//  ParraFeedbackFormTextFieldView.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 6/11/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import ParraCore
import SwiftUI
import Combine

struct ParraFeedbackFormTextFieldView: ParraFeedbackFormFieldView {
    typealias FieldData = FeedbackFormTextFieldData

    @State var formId: String
    @State var field: FeedbackFormField
    @State var fieldData: FieldData
    @State var onFieldDataChanged: ParraFeedbackFormFieldUpdateHandler

    @State private var text = ""
    @State private var isFeedbackTextValid = false

    var body: some View {
        let errorMessage = validate(
            text: text.trimmingCharacters(in: .whitespacesAndNewlines),
            data: fieldData,
            requiredField: field.required ?? false
        )

        VStack(spacing: 5) {
            let textEditor = TextEditor(text: $text)
                .frame(minHeight: 100, idealHeight: 100, maxHeight: 240)
                .padding()
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .onReceive(Just(text)) { newValue in
                    onFieldDataChanged(field.name, newValue, errorMessage == nil)
                }

            if #available(iOS 16.0, *) {
                textEditor.lineLimit(3...)
            } else {
                textEditor
            }

            HStack {
                Spacer()

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.trailing, 4)
                } else {
                    let characterCount = text.count

                    Text(fieldData.maxCharacters == nil
                         ? characterCount.simplePluralized(singularString: "character")
                         : "\(characterCount)/\(fieldData.maxCharacters!)"
                    )
                    .foregroundColor(.secondary)
                    .padding(.trailing, 4)
                }
            }
        }
    }

    private func validate(
        text: String,
        data: FeedbackFormTextFieldData,
        requiredField: Bool
    ) -> String? {
        var rules = [TextValidatorRule]()

        if let minCharacters = data.minCharacters {
            rules.append(.minLength(minCharacters))
        }

        if let maxCharacters = data.maxCharacters {
            rules.append(.maxLength(maxCharacters))
        }

        return TextValidator.validate(
            text: text,
            against: rules,
            requiredField: requiredField
        )
    }
}
