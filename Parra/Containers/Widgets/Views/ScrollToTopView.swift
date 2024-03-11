//
//  ScrollToTopView.swift
//  Parra
//
//  Created by Mick MacCallum on 3/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ScrollToTopView<T>: View where T: Equatable {
    let reader: ScrollViewProxy
    let animateChanges: Bool

    @Binding var scrollOnChange: T

    var body: some View {
        EmptyView()
            .id("topScrollPoint")
            .onChange(of: scrollOnChange) { _, _ in
                if animateChanges {
                    withAnimation {
                        reader.scrollTo("topScrollPoint", anchor: .bottom)
                    }
                } else {
                    reader.scrollTo("topScrollPoint", anchor: .bottom)
                }
            }
    }
}
