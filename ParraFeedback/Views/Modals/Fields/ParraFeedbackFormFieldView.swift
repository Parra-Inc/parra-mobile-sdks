//
//  ParraFeedbackFormFieldView.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 6/11/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import SwiftUI
import ParraCore

typealias ParraFeedbackFormFieldUpdateHandler = (_ name: String, _ value: String?, _ valid: Bool) -> Void

protocol ParraFeedbackFormFieldView: View {
    associatedtype FieldData: FeedbackFormFieldDataType

    var formId: String { get set }
    var field: FeedbackFormField { get set }
    var fieldData: FieldData { get set }
    var onFieldDataChanged: ParraFeedbackFormFieldUpdateHandler { get set }
}
