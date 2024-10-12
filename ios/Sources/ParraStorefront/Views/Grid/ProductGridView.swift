//
//  ProductGridView.swift
//  Parra
//
//  Created by Mick MacCallum on 9/30/24.
//

import SwiftUI

struct ProductGridView: View {
    // MARK: - Internal

    let products: [ParraProduct]

    var body: some View {
        let cellSpacing: CGFloat = 18

        GeometryReader { geometry in
            let columns = gridLayout.getColumns(
                in: geometry,
                with: cellSpacing
            )

            ScrollView {
                LazyVGrid(
                    columns: columns,
                    spacing: cellSpacing
                ) {
                    ForEach(products) { product in
                        NavigationLink(
                            value: product
                        ) {
                            ProductCell(product: product)
                        }
                        .buttonStyle(ProductCellButtonStyle())
                        .disabled(!redactionReasons.isEmpty)
                    }
                }
                .padding(.horizontal, cellSpacing)
                .padding(.bottom, cellSpacing)
            }
            .scrollDisabled(!redactionReasons.isEmpty)
            .refreshable {
                contentObserver.refresh()
            }
        }
    }

    // MARK: - Private

    @State private var gridLayout: GridLayout = .twoColumn
    @Environment(\.redactionReasons) private var redactionReasons
    @Environment(StorefrontWidget.ContentObserver.self) private var contentObserver
}
