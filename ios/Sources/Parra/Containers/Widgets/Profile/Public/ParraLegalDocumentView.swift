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

    public init(legalDocument: ParraLegalDocument) {
        self.legalDocument = legalDocument
    }

    // MARK: - Public

    public let legalDocument: ParraLegalDocument

    public var body: some View {
        WebView(
            url: URL(string: "")!
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}
