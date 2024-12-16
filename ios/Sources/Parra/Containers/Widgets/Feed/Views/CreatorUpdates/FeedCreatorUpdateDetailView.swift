//
//  FeedCreatorUpdateDetailView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/16/24.
//

import SwiftUI

struct FeedCreatorUpdateDetailView: View {
    // MARK: - Internal

    let creatorUpdate: ParraCreatorUpdateAppStub
    let feedItemId: String
    @ObservedObject var reactor: FeedItemReactor

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                FeedCreatorUpdateDetailHeaderView(
                    creatorUpdate: creatorUpdate,
                    feedItemId: feedItemId,
                    containerGeometry: geometry,
                    reactor: reactor
                )
            }
            .background(parraTheme.palette.secondaryBackground)
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ParraDismissButton()
            }
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme
    @Environment(FeedWidget.ContentObserver.self) private var contentObserver
    @Environment(\.presentationMode) private var presentationMode
}
