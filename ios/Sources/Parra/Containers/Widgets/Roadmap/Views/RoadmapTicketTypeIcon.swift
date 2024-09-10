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

    let type: ParraTicketType

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
        .applyCornerRadii(size: .xs, from: parraTheme)
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var parraTheme
}

#Preview {
    ParraViewPreview { _ in
        VStack {
            RoadmapTicketTypeIcon(type: .bug)
            RoadmapTicketTypeIcon(type: .feature)
            RoadmapTicketTypeIcon(type: .improvement)
            RoadmapTicketTypeIcon(type: .task)
        }
    }
}
