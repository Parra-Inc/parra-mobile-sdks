//
//  ReactionWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 12/11/24.
//

import SwiftUI

struct ReactionWidget: ParraContainer {
    // MARK: - Lifecycle

    init(
        config: ParraRoadmapWidgetConfig,
        contentObserver: ContentObserver
    ) {
        self.config = config
        self._contentObserver = StateObject(wrappedValue: contentObserver)
    }

    // MARK: - Internal

    @StateObject var contentObserver: ContentObserver
    let config: ParraRoadmapWidgetConfig

//    var items: Binding<[TicketUserContent]> {
//        return $contentObserver.ticketPaginator.items
//    }

    var body: some View {
        EmptyView()
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraConfiguration) private var parraConfiguration
    @Environment(\.parraTheme) private var parraTheme
}

#Preview {
    ParraContainerPreview<ReactionWidget>(
        config: .default
    ) { parra, _, config in
        ReactionWidget(
            config: config,
            contentObserver: .init(
                initialParams: ReactionWidget.ContentObserver.InitialParams(
                    //                    roadmapConfig: ParraAppRoadmapConfiguration.validStates()[0],
//                    selectedTab: ParraAppRoadmapConfiguration.validStates()[0]
//                        .tabs.elements[0],
//                    ticketResponse: ParraUserTicketCollectionResponse
//                        .validStates()[0],
                    api: parra.parraInternal.api
                )
            )
        )
    }
}
