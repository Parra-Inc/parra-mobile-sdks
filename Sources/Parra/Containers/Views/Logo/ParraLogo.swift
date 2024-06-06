//
//  ParraLogo.swift
//  Parra
//
//  Created by Mick MacCallum on 1/19/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI
import UIKit

struct ParraLogo: View {
    // MARK: - Lifecycle

    init(type: ParraLogoType) {
        self.type = type
    }

    // MARK: - Internal

    var type: ParraLogoType

    @ViewBuilder var logoRight: some View {
        switch type {
        case .logo:
            EmptyView()
        case .logoAndText, .poweredBy:
            Image(uiImage: getLogoImage(of: type)!)
                .resizable()
                .frame(width: textSize.width, height: textSize.height)
        }
    }

    @ViewBuilder var logo: some View {
        HStack(alignment: .center, spacing: elementSpacing) {
            Image(uiImage: getLogoImage(of: .logo)!)
                .resizable()
                .frame(width: iconSize, height: iconSize)

            logoRight
        }
    }

    var body: some View {
        logo
    }

    // MARK: - Private

    private var iconSize: Double {
        return switch type {
        case .logo:
            132
        case .logoAndText:
            132
        case .poweredBy:
            16
        }
    }

    private var textSize: CGSize {
        return switch type {
        case .logo:
            .zero
        case .logoAndText:
            CGSize(width: 318, height: 80)
        case .poweredBy:
            CGSize(width: 98, height: 12)
        }
    }

    private var elementSpacing: Double {
        return switch type {
        case .logo:
            0
        case .logoAndText:
            24
        case .poweredBy:
            6
        }
    }

    private func getLogoImage(of type: ParraLogoType) -> UIImage? {
        let name = switch type {
        case .logo:
            "ParraLogo"
        case .logoAndText:
            "ParraName"
        case .poweredBy:
            "PoweredByParra"
        }

        return UIImage(
            named: name,
            in: .parraBundle,
            with: nil
        )
    }
}

#Preview("Parra Logos", traits: .sizeThatFitsLayout) {
    ParraViewPreview { _ in
        VStack(alignment: .center, spacing: 70) {
            VStack(alignment: .center, spacing: 20) {
                ParraLogo(type: .logo)
                ParraLogo(type: .logoAndText)
                ParraLogo(type: .poweredBy)
            }
            .padding(30)
            .environment(\.colorScheme, .light)
            .background(.white)

            VStack(alignment: .center, spacing: 20) {
                ParraLogo(type: .logo)
                ParraLogo(type: .logoAndText)
                ParraLogo(type: .poweredBy)
            }
            .padding(30)
            .environment(\.colorScheme, .dark)
            .background(.black)
        }
        .padding()
    }
}
