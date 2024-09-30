//
//  SizePreferenceKey.swift
//  Parra
//
//  Created by Mick MacCallum on 9/30/24.
//

import SwiftUI

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(
        value: inout CGSize, nextValue: () -> CGSize
    ) {
        value = nextValue()
    }
}

struct SizeCalculator: ViewModifier {
    func body(
        content: Content
    ) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: SizePreferenceKey.self,
                        value: geometry.size
                    )
                }
            )
    }
}
