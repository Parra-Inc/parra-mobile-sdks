//
//  ParraLegalDocumentView.swift
//  Parra
//
//  Created by Mick MacCallum on 7/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraLegalDocumentView: View {
    // MARK: - Lifecycle

    public init(legalDocument: LegalDocument) {
        self.legalDocument = legalDocument
    }

    // MARK: - Public

    public let legalDocument: LegalDocument

    public var body: some View {
        WebView(
            url: legalDocument.url
        )
    }
}
