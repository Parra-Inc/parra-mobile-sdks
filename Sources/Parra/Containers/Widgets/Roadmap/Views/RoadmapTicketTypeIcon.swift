//
//  RoadmapTicketTypeIcon.swift
//  Parra
//
//  Created by Mick MacCallum on 3/12/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct RoadmapTicketTypeIcon: View {
    // MARK: - Internal

    let type: TicketType

    var body: some View {
        VStack {
            Image(systemName: type.symbolName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(
                    width: type.imageSize.width,
                    height: type.imageSize.height
                )
                .foregroundColor(.white)
        }
        .frame(width: type.size.width, height: type.size.height)
        .background(type.backgroundColor)
        .applyCornerRadii(size: .xs, from: themeObserver.theme)
    }

    // MARK: - Private

    @EnvironmentObject private var themeObserver: ParraThemeObserver
}

#Preview {
    ParraViewPreview { _ in
        VStack {
            RoadmapTicketTypeIcon(type: .bug)
            RoadmapTicketTypeIcon(type: .feature)
            RoadmapTicketTypeIcon(type: .improvement)
        }
    }
}
