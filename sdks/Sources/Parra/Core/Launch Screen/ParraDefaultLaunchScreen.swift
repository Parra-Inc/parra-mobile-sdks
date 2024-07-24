//
//  ParraDefaultLaunchScreen.swift
//  Parra
//
//  Created by Mick MacCallum on 2/14/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// TODO: Toolbar doesn't seem to work on the iOS launch screen so not sure
// how to handle it here.

/// A launch screen using the modern SwiftUI way of rendering launch screens via
/// a few customizable properties, instead of an arbitrary storyboard. When
/// using this launch screen, provide a ``Config`` object specifying the
/// properties of the launch screen. Any properties that are omitted will fall
/// back on their associated values in your info.plist, as defined in Apple's
/// documentation [here](https://developer.apple.com/documentation/bundleresources/information_property_list/uilaunchscreen).
public struct ParraDefaultLaunchScreen: View {
    // MARK: - Lifecycle

    init(
        config: Config
    ) {
        self.config = config
    }

    // MARK: - Public

    public var body: some View {
        // I can't work out why, but without using a geometry reader to set the
        // width and height of the Image, it is shifted about 25 points lower
        // than the system launch screen. Doing this allows for perfect
        // alignment and no hard transition.
        // Also note that the safe area had to be accessed in an alternative way
        // because we have to ignore it on the parent view, even if we're taking
        // it into consideration for image padding under some conditions.
        GeometryReader { geometry in
            ZStack {
                backgroundColor
                image
                barOverlay(with: geometry)
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height,
                alignment: .center
            )
        }
        .ignoresSafeArea()
    }

    // MARK: - Private

    @Environment(\.defaultSafeAreaInsets) private var defaultSafeAreaInsets

    private let config: Config

    @ViewBuilder private var image: some View {
        if let imageName = config.imageName {
            Image(imageName)
                .padding(
                    config
                        .imageRespectsSafeAreaInsets == true ?
                        defaultSafeAreaInsets : .zero
                )
        } else {
            EmptyView()
        }
    }

    @ViewBuilder private var backgroundColor: some View {
        if let colorName = config.colorName {
            Color(colorName)
        } else {
            Color(UIColor.systemBackground)
        }
    }

    @ViewBuilder
    private func renderImageOrBlurBar(
        named imageName: String?,
        size: CGSize
    ) -> some View {
        if let imageName {
            Image(imageName)
                .resizable()
                .frame(
                    width: size.width,
                    height: size.height
                )
                .clipped()
        } else {
            Color.clear
                .background(.regularMaterial)
                .frame(
                    width: size.width,
                    height: size.height
                )
        }
    }

    @ViewBuilder
    private func barOverlay(with geometry: GeometryProxy) -> some View {
        // TODO: Figure this out without magic numbers.

        VStack {
            if let navigationBar = config.navigationBar {
                renderImageOrBlurBar(
                    named: navigationBar.replacementImage,
                    size: CGSize(
                        width: geometry.size.width,
                        height: defaultSafeAreaInsets.top + 44
                    )
                )
            }

            Spacer()
                .layoutPriority(100)

            if let tabBar = config.tabBar {
                renderImageOrBlurBar(
                    named: tabBar.replacementImage,
                    size: CGSize(
                        width: geometry.size.width,
                        height: defaultSafeAreaInsets.bottom + 83
                    )
                )
            }
        }
        .frame(
            width: geometry.size.width,
            height: geometry.size.height
        )
    }
}

#Preview {
    ParraDefaultLaunchScreen(
        config: .init(
            colorName: "AccentColor",
            imageName: "splash",
            imageRespectsSafeAreaInsets: nil,
            navigationBar: .init(replacementImage: "navigation"),
            tabBar: .init(replacementImage: "tab"),
            toolBar: nil,
            bundle: .main
        )
    )
}

#Preview {
    ParraDefaultLaunchScreen(
        config: .init(
            colorName: "AccentColor",
            imageName: "splash",
            imageRespectsSafeAreaInsets: nil,
            navigationBar: .init(replacementImage: nil),
            tabBar: .init(replacementImage: nil),
            toolBar: nil,
            bundle: .main
        )
    )
}
