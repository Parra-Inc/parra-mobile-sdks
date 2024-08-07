//
//  View+Release.swift
//  Parra
//
//  Created by Mick MacCallum on 3/25/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension View {
    /// Automatically fetches the feedback form with the provided id and
    /// presents it in a sheet based on the value of the `isPresented` binding.
    @MainActor
    func presentParraRelease(
        with appVersionInfoBinding: Binding<ParraNewInstalledVersionInfo?>,
        config: ParraChangelogWidgetConfig = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        return loadAndPresentSheet(
            loadType: .init(
                get: {
                    if let appVersionInfo = appVersionInfoBinding.wrappedValue {
                        return .raw(.newInstalledVersion(appVersionInfo))
                    } else {
                        return nil
                    }
                },
                set: { type in
                    if type == nil {
                        appVersionInfoBinding.wrappedValue = nil
                    }
                }
            ),
            with: .releaseLoader(
                config: config
            ),
            onDismiss: onDismiss
        )
    }

    // TODO: support this
//    @MainActor
//    func presentParraReleaseToast(
//        with appVersionInfoBinding: Binding<NewInstalledVersionInfo?>,
//        config: ChangelogWidgetConfig = .default,
//        onDismiss: ((SheetDismissType) -> Void)? = nil
//    ) -> some View {
//        return loadAndPresentSheet(
//            loadType: .init(
//                get: {
//                    if let appVersionInfo = appVersionInfoBinding.wrappedValue {
//                        return .raw(.newInstalledVersion(appVersionInfo))
//                    } else {
//                        return nil
//                    }
//                },
//                set: { type in
//                    if type == nil {
//                        appVersionInfoBinding.wrappedValue = nil
//                    }
//                }
//            ),
//            with: .releaseLoader(
//                config: config
//            ),
//            onDismiss: onDismiss
//        )
//    }
}
