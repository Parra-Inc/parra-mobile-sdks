//
//  View+Roadmap.swift
//  Parra
//
//  Created by Mick MacCallum on 3/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension View {
    /// Automatically fetches the feedback form with the provided id and
    /// presents it in a sheet based on the value of the `isPresented` binding.
    @MainActor
    func presentParraRoadmap(
        isPresented: Binding<Bool>,
        config: RoadmapWidgetConfig = .default,
        localBuilder: RoadmapWidgetBuilderConfig = .init(),
        defaultTab: ParraRoadmapTab = .inProgress,
        onDismiss: ((SheetDismissType) -> Void)? = nil
    ) -> some View {
        let params = RoadmapParams(
            limit: 15,
            offset: 0,
            filter: defaultTab.filter
        )

        return loadAndPresentSheet(
            loadType: .init(
                get: {
                    if isPresented.wrappedValue {
                        return .transform(params)
                    } else {
                        return nil
                    }
                },
                set: { type in
                    if type == nil {
                        isPresented.wrappedValue = false
                    }
                }
            ),
            with: .roadmapLoader(
                config: config,
                localBuilder: localBuilder
            ),
            onDismiss: onDismiss
        )
    }
}
