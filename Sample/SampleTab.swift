//
//  SampleTab.swift
//  Sample
//
//  Created by Mick MacCallum on 4/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Parra
import SwiftUI

struct SampleTab: View {
    var body: some View {
        ZStack {
            GridBackgroundView()
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Text("We can't wait to see\nwhat you build!")
                    .font(.largeTitle).bold()
                    .multilineTextAlignment(.center)

                Link(
                    destination: URL(
                        string: "https://docs.parra.io/sdks/guides/quickstart/swiftui"
                    )!
                ) {
                    Text("Get started")
                }
            }
        }
    }
}

#Preview {
    ParraAppPreview {
        SampleTab()
    }
}

struct GridBackgroundView: View {
    var body: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(
                    colors: [
                        UIColor.systemBackground.toParraColor(),
                        UIColor.systemBackground.toParraColor(),
                        UIColor.systemBackground.toParraColor().opacity(0.001)
                    ]
                ),
                center: .center,
                startRadius: 0,
                endRadius: 500
            )
            .edgesIgnoringSafeArea(.all)
            .background {
                AnimatedBackground()
                    .blur(radius: 150)
            }

            // Grid
            Canvas { context, size in
                let spacing: CGFloat = 20
                let lightLine = Path { path in
                    // Vertical lines
                    for x in stride(from: 0, through: size.width, by: spacing) {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                    }
                    // Horizontal lines
                    for y in stride(
                        from: 0,
                        through: size.height,
                        by: spacing
                    ) {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                    }
                }

                context.stroke(
                    lightLine,
                    with: .color(
                        UIColor.systemBackground.toParraColor().opacity(0.2)
                    ),
                    lineWidth: 1
                )
            }
            .blendMode(.overlay)
        }
    }
}

public extension Text {
    func foregroundLinearGradient(
        color: Color,
        startPoint: UnitPoint,
        endPoint: UnitPoint
    ) -> some View {
        overlay {
            Rectangle().fill(color.gradient).mask(
                self
            )
        }
    }
}

struct AnimatedBackground: View {
    @State var start = UnitPoint(x: 0, y: -2)
    @State var end = UnitPoint(x: 4, y: 0)

    @EnvironmentObject private var themeObserver: ParraThemeObserver

    let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()

    var body: some View {
        let palette = themeObserver.theme.palette
        let colors = [
            palette.primary.shade300.toParraColor(),
            palette.primary.shade300.toParraColor(),
            palette.primary.shade600.toParraColor()
        ]

        LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: start,
            endPoint: end
        )
        .animation(
            Animation.easeInOut(duration: 6).repeatForever(),
            value: start
        )
        .onReceive(timer) { _ in
            start = UnitPoint(x: 4, y: 0)
            end = UnitPoint(x: 0, y: 2)
            start = UnitPoint(x: -4, y: 20)
            start = UnitPoint(x: 4, y: 0)
        }
    }
}
