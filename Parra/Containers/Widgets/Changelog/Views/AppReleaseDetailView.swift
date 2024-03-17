//
//  AppReleaseDetailView.swift
//  Parra
//
//  Created by Mick MacCallum on 3/17/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct AppReleaseDetailView: View {
    var content: AppReleaseContent

    @Environment(ChangelogWidgetConfig.self) var config
    @Environment(ChangelogWidgetBuilderConfig.self) var builderConfig
    @EnvironmentObject var contentObserver: RoadmapWidget.ContentObserver
    @EnvironmentObject var componentFactory: ComponentFactory
    @EnvironmentObject var themeObserver: ParraThemeObserver

    var body: some View {
//        let palette = themeObserver.theme.palette

        EmptyView()
    }
}
