//
//  ParraFeedbackFormTextFieldView.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 6/11/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

fileprivate let minLines = 3

struct ParraFeedbackFormTextFieldView: ParraFeedbackFormFieldView {
    typealias DataType = FeedbackFormTextFieldData

    var fieldWithState: FormFieldWithState
    var fieldData: FormFieldWithTypedData<FeedbackFormTextFieldData>

    var onFieldValueChanged: ((FeedbackFormField, String?) -> Void)?

    @State private var text = ""
    @State private var hasReceivedInput = false

    private var maxLines: Int {
        guard let maxLines = fieldData.data.maxLines else {
            return 10
        }

        // Don't allow a max that is less than the min.
        return max(minLines, maxLines)
    }

    private var textEditor: some View {
        TextEditor(text: $text)
            .frame(
                minHeight: 60,
                idealHeight: 100,
                maxHeight: CGFloat(fieldData.data.maxHeight ?? 240)
            )
            .padding(6)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .lineLimit(minLines...maxLines)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .onChange(of: text) { _, newValue in
                hasReceivedInput = true
                onFieldValueChanged?(fieldWithState.field, newValue)
            }
    }

    @ViewBuilder
    private var inputMessage: some View {

        switch fieldWithState.state {
        case .valid:
            let characterCount = text.count

            Text(fieldData.data.maxCharacters == nil
                 ? characterCount.simplePluralized(singularString: "character")
                 : "\(characterCount)/\(fieldData.data.maxCharacters!)"
            )
            .foregroundColor(.secondary)
            .padding(.trailing, 4)
        case .invalid(let errorMessage):
            Text(errorMessage)
                .foregroundColor(hasReceivedInput ? .red : .gray)
                .padding(.trailing, 4)
        }
    }

    var body: some View {
        VStack(spacing: 5) {
            textEditor

            HStack {
                Spacer()

                inputMessage
            }
        }
    }
}

#Preview {
    ParraFeedbackFormTextFieldView.DataType.renderValidStates { fieldData in
        ParraFeedbackFormTextFieldView(
            fieldWithState: .init(field: .init(name: "", title: "", helperText: "", type: .select, required: true, data: .feedbackFormTextFieldData(fieldData))),
            fieldData: .init(data: fieldData)
        )
    }
}