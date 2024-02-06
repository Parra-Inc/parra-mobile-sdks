//
//  TextEditorContent.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

internal struct TextEditorContent {
    internal let placeholder: String?
    internal let errorMessage: String?
    internal let textChanged: ((String?) -> Void)?
}
