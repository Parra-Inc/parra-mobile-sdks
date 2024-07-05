//
//  ParraLegalInfoView.swift
//  Parra
//
//  Created by Mick MacCallum on 7/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraLegalInfoView: View {
    // MARK: - Lifecycle

    public init() {}

    // MARK: - Public

    public var body: some View {
        List(parraAppInfo.legal.allDocuments) { document in
            NavigationLink {
                ParraLegalDocumentView(legalDocument: document)
            } label: {
                Text(document.title)
            }
            .id(document.id)
        }
        .navigationTitle("Legal Info")
        .navigationBarTitleDisplayMode(.automatic)
    }

    // MARK: - Private

    @EnvironmentObject private var parraAppInfo: ParraAppInfo
}

#Preview {
    ParraViewPreview { _ in
        ParraLegalInfoView()
    }
}
