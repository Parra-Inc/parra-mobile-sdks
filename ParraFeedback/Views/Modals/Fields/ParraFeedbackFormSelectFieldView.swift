//
//  ParraFeedbackFormSelectFieldView.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 6/11/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import ParraCore
import SwiftUI

struct ParraFeedbackFormSelectFieldView: ParraFeedbackFormFieldView {
    typealias FieldData = FeedbackFormSelectFieldData

    @State var formId: String
    @State var field: FeedbackFormField
    @State var fieldData: FieldData
    @State var onFieldDataChanged: ParraFeedbackFormFieldUpdateHandler

    @State private var selectedType = ""

    var body: some View {
        Picker("Type of Feedback", selection: $selectedType) {
            Text(fieldData.placeholder ?? "Select an Option").tag(nil as Int?)

            ForEach(fieldData.options) { option in
                Text(option.title).tag(option.value)
            }
        }
        .accentColor(.gray)
        .pickerStyle(.menu)
        .padding()
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1)
        )
        .onChange(of: selectedType) { newValue in
            onFieldDataChanged(field.name, newValue, !selectedType.isEmpty)
        }
    }
}
