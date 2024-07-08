//
//  LegalInfoCell.swift
//  Sample
//
//  Created by Mick MacCallum on 7/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Parra
import SwiftUI

struct LegalInfoCell: View {
    var body: some View {
        NavigationLink {
            ParraLegalInfoView()
        } label: {
            Label(
                title: { Text("Legal documents") },
                icon: { Image(systemName: "doc.text") }
            )
        }
        .foregroundStyle(.blue)
    }
}

#Preview {
    ParraAppPreview {
        LegalInfoCell()
    }
}
