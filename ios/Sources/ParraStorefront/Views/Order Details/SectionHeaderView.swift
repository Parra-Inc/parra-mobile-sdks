//
//  SectionHeaderView.swift
//  Parra
//
//  Created by Mick MacCallum on 11/8/24.
//

import Parra
import SwiftUI

struct SectionHeaderView: View {
    // MARK: - Internal

    let title: String

    var body: some View {
        componentFactory.buildLabel(
            text: title,
            localAttributes: ParraAttributes.Label(
                text: .init(
                    style: .title3,
                    weight: .medium
                )
            )
        )
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
}
