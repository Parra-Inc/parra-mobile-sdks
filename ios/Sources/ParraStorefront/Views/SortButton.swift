//
//  SortButton.swift
//  Parra
//
//  Created by Mick MacCallum on 1/9/25.
//

import Buy
import SwiftUI

struct SortButton: View {
    struct SortLabelStyle: LabelStyle {
        let isSelected: Bool

        func makeBody(configuration: Configuration) -> some View {
            if isSelected {
                configuration.icon
            }

            configuration.title
        }
    }

    @Binding var sortOrder: ProductSortOrder

    var body: some View {
        Menu("Filter & Sort", systemImage: "line.3.horizontal.decrease.circle") {
            Section("Sort") {
                ForEach(ProductSortOrder.allCases, id: \.self) { option in
                    Button {
                        sortOrder = option
                    } label: {
                        Label(option.name, systemImage: "checkmark")
                            .labelStyle(
                                SortLabelStyle(isSelected: sortOrder == option)
                            )
                    }
                    .tag(option)
                }
            }
        }
    }
}
