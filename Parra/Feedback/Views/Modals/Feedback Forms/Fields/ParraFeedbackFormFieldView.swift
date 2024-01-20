//
//  ParraFeedbackFormFieldView.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 6/11/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import SwiftUI

internal struct FormFieldWithTypedData<DataType: FeedbackFormFieldDataType> {
    let data: DataType
}

internal protocol ParraFeedbackFormFieldView: View {
    associatedtype DataType: FeedbackFormFieldDataType

    var fieldWithState: FormFieldWithState { get set }
    var fieldData: FormFieldWithTypedData<DataType> { get set }

    var onFieldValueChanged: ((_ field: FeedbackFormField, _ value: String?) -> Void)? { get set }
}
