//
//  ViewfinderView.swift
//  Parra
//
//  Created by Mick MacCallum on 4/26/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ViewfinderView: View {
    @Binding var image: Image?

    var body: some View {
        GeometryReader { geometry in
            if let image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
            }
        }
    }
}

#Preview {
    ViewfinderView(image: .constant(Image(systemName: "pencil")))
}
