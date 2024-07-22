//
//  SheetStateContainer.swift
//  Parra
//
//  Created by Mick MacCallum on 7/22/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct SheetStateContainer<Data, Content>: View, Equatable
    where Data: Equatable, Content: View
{
    // MARK: - Internal

    var data: Data
    var content: () -> Content

    var body: some View {
        NavigationStack(path: $navigationState.navigationPath) {
            content()
                .environmentObject(navigationState)
                .padding(.top, 30)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    static func == (
        lhs: SheetStateContainer<Data, Content>,
        rhs: SheetStateContainer<Data, Content>
    ) -> Bool {
        return lhs.data == rhs.data
    }

    // MARK: - Private

    @StateObject private var navigationState = NavigationState()
}
