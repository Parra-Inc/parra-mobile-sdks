//
//  ProductGridView.swift
//  Parra
//
//  Created by Mick MacCallum on 9/30/24.
//

import Parra
import SwiftUI
import UIKit

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

            ParraMediaAwareScrollView {
                LazyVGrid(
                    columns: columns,
                    spacing: cellSpacing
                ) {
                    ForEach(products) { product in
                        NavigationLink {
                            ProductDetailView(product: product)
                                .environment(contentObserver)
                        } label: {
                            ProductCell(product: product)
                        }
                        .buttonStyle(ProductCellButtonStyle())
                        .disabled(redactionReasons.contains(.placeholder))
                    }
                }
                .padding(.horizontal, cellSpacing)
                .padding(.bottom, cellSpacing)
            }
            .scrollDisabled(redactionReasons.contains(.placeholder))
            .refreshable {
                await contentObserver.refresh()
            }
        }
    }

    // MARK: - Private

    @State private var gridLayout: GridLayout = UIDevice.current
        .userInterfaceIdiom == .pad ? .fourColumn : .twoColumn
    @Environment(\.redactionReasons) private var redactionReasons
    @Environment(StorefrontWidget.ContentObserver.self) private var contentObserver
}
