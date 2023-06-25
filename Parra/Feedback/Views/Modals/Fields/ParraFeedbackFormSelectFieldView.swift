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
    typealias FieldData = FeedbackFormSelectFieldData

    @State var formId: String
    @State var field: FeedbackFormField
    @State var fieldData: FieldData
    @State var onFieldDataChanged: ParraFeedbackFormFieldUpdateHandler

    @State private var selectedType: String?

    var body: some View {
        Picker(field.title ?? "", selection: $selectedType) {
            // Only show the nil option if a selection hasn't been made yet.
            if selectedType == nil {
                Text(fieldData.placeholder ?? "Select an Option").tag(nil as String?)
            }

            ForEach(fieldData.options) { option in
                // Tag value must be wrapped in optional to continue to allow selection if a nil option is present.
                Text(option.title).tag(Optional(option.value))
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
            let valid = !(selectedType?.isEmpty ?? true)
            onFieldDataChanged(field.name, newValue, valid)
        }
    }
}
