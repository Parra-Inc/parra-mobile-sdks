//
//  ParraFeedbackFormSelectFieldView.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 6/11/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import SwiftUI

struct ParraFeedbackFormSelectFieldView: ParraFeedbackFormFieldView {
    typealias DataType = FeedbackFormSelectFieldData

    var fieldWithState: FormFieldWithState
    var fieldData: FormFieldWithTypedData<FeedbackFormSelectFieldData>
    var onFieldValueChanged: ((FeedbackFormField, String?) -> Void)?

    @State private var selectedOption: FeedbackFormSelectFieldOption?

    private var elementOpacity: Double {
        return selectedOption != nil ? 1.0 : 1
    }

    @ViewBuilder
    private func menuItem(for index: Int) -> some View {
        let option = fieldData.data.options[index]

        if option == selectedOption {
            Button(option.title, systemImage: "checkmark") {
                didSelect(fieldOption: option)
            }
        } else {
            Button(option.title) {
                didSelect(fieldOption: option)
            }
        }
    }

    @ViewBuilder
    private var menuLabel: some View {
        let common = Text(selectedOption?.title ?? fieldData.data.placeholder ?? "Select an Option")
            .font(.body)
            .foregroundStyle(.primary.opacity(elementOpacity))
            .padding(.vertical, 18.5)

        if selectedOption == nil {
            common
        } else {
            common
                .fontWeight(.medium)
        }
    }

    var body: some View {
        Menu {
            ForEach(fieldData.data.options.indices, id: \.self) { index in
                menuItem(for: index)
            }
        } label: {
            HStack {
                menuLabel

                Spacer()

                Image(systemName: "chevron.up.chevron.down")
                    .padding(.vertical, 16)
                    .foregroundStyle(.primary.opacity(elementOpacity))
                    .frame(width: 24, height: 24)
            }
        }
        .menuOrder(.fixed)
        .tint(.primary.opacity(0.6))
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.gray, lineWidth: 1)
        )
    }

    private func didSelect(fieldOption: FeedbackFormSelectFieldOption) {
        selectedOption = fieldOption

        onFieldValueChanged?(fieldWithState.field, fieldOption.value)
    }
}

#Preview {
    ParraFeedbackFormSelectFieldView.DataType.renderValidStates { fieldData in
        ParraFeedbackFormSelectFieldView(
            fieldWithState: .init(field: .init(name: "", title: "", helperText: "", type: .select, required: true, data: .feedbackFormSelectFieldData(fieldData))),
            fieldData: .init(data: fieldData)
        )
    }
}
