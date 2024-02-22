//
//  FeedbackCardWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 2/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// TODO: How can the `Factory` type provided to this widget allow overriding
// elements dynamically by card type?

struct FeedbackCardWidget: Container {
    typealias Factory = FeedbackFormWidgetComponentFactory
    typealias Config = FeedbackCardConfig
    typealias ContentObserver = FeedbackCardContentObserver
    typealias Style = WidgetStyle

    var componentFactory: ComponentFactory<Factory>
    @StateObject var contentObserver: ContentObserver
    var config: Config = .default
    @EnvironmentObject var themeObserver: ParraThemeObserver

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    ParraContainerPreview { componentFactory in
        FeedbackCardWidget(
            componentFactory: componentFactory,
            contentObserver: FeedbackCardContentObserver()
        )
    }
}
