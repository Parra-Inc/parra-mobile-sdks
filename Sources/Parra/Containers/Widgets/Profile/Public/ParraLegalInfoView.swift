//
//  ParraLegalInfoView.swift
//  Parra
//
//  Created by Mick MacCallum on 7/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraLegalInfoView: View {
    // MARK: - Public

    public var body: some View {
        List(parraAppInfo.legal.allDocuments) { document in
            NavigationLink(value: document) {
                Text(document.title)
            }
        }
        .navigationTitle("Legal Info")
        .navigationDestination(for: LegalDocument.self) { item in
            ParraLegalDocumentView(legalDocument: item)
        }
    }

    // MARK: - Private

    @EnvironmentObject private var parraAppInfo: ParraAppInfo
}

#Preview {
    ParraViewPreview { _ in
        NavigationStack {
            ParraLegalInfoView()
        }
    }
}
