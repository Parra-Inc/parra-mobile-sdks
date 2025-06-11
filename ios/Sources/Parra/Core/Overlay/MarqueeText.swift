//
//  MarqueeText.swift
//  Parra
//
//  Created by Mick MacCallum on 5/23/25.
//

import SwiftUI

struct MarqueeText: View {
    // MARK: - Lifecycle

    init(
        text: String,
        font: Font,
        leftFade: CGFloat = 20,
        rightFade: CGFloat = 20,
        startDelay: TimeInterval = 2.0,
        alignment: Alignment = .leading
    ) {
        self.text = text
        self.font = font
        self.startDelay = startDelay
        self.alignment = alignment
        self.leftFade = leftFade
        self.rightFade = rightFade
    }

    // MARK: - Internal

    var text: String
    var font: Font
    var leftFade: CGFloat
    var rightFade: CGFloat
    var startDelay: TimeInterval
    var alignment: Alignment

    var isCompact = false

    var body: some View {
        let stringWidth = text.widthOfString(usingFont: font)
        let stringHeight = text.heightOfString(usingFont: font)

        // Create our animations
        let animation = Animation
            .linear(duration: Double(stringWidth) / 30)
            .delay(startDelay)
            .repeatForever(autoreverses: false)

        let nullAnimation = Animation.linear(duration: 0)

        GeometryReader { geo in
            // Decide if scrolling is needed
            let needsScrolling = (stringWidth > geo.size.width)

            ZStack {
                if needsScrolling {
                    // MARK: - Scrolling (Marquee) version

                    makeMarqueeTexts(
                        stringWidth: stringWidth,
                        stringHeight: stringHeight,
                        geoWidth: geo.size.width,
                        animation: animation,
                        nullAnimation: nullAnimation
                    )
                    // force left alignment when scrolling
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        maxHeight: .infinity,
                        alignment: .topLeading
                    )
                    .offset(x: leftFade)
                    .mask(
                        fadeMask(
                            leftFade: leftFade,
                            rightFade: rightFade
                        )
                    )
                    .frame(width: geo.size.width + leftFade)
                    .offset(x: -leftFade)
                } else {
                    // MARK: - Non-scrolling version

                    Text(text)
                        .font(.init(font))
                        .onChange(of: text) { _, _ in
                            animate = false // No scrolling needed
                        }
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 0,
                            maxHeight: .infinity,
                            alignment: alignment // use alignment only if not scrolling
                        )
                }
            }
            .onAppear {
                // Trigger scrolling if needed
                animate = isEnabled && needsScrolling
            }
            .onChange(
                of: isEnabled,
                initial: true
            ) { _, newValue in
                if newValue && needsScrolling {
                    animate = true
                }
            }
            .onChange(of: text) { _, newValue in
                let newStringWidth = newValue.widthOfString(usingFont: font)
                if newStringWidth > geo.size.width {
                    // Stop the old animation first
                    animate = false

                    // Kick off a new animation on the next runloop
                    DispatchQueue.main.async {
                        animate = true
                    }
                } else {
                    animate = false
                }
            }
        }
        .frame(height: stringHeight)
        .frame(maxWidth: isCompact ? stringWidth : nil)
        .onDisappear {
            animate = false
        }
    }

    // MARK: - Private

    @State private var animate = false
    @Environment(\.isEnabled) private var isEnabled

    // MARK: - Marquee pair of texts

    @ViewBuilder
    private func makeMarqueeTexts(
        stringWidth: CGFloat,
        stringHeight: CGFloat,
        geoWidth: CGFloat,
        animation: Animation,
        nullAnimation: Animation
    ) -> some View {
        // Two stacked texts moving across in opposite phases
        Group {
            Text(text)
                .lineLimit(1)
                .font(.init(font))
                .offset(x: animate ? -stringWidth - stringHeight * 2 : 0)
                .animation(animate ? animation : nullAnimation, value: animate)
                .fixedSize(horizontal: true, vertical: false)

            Text(text)
                .lineLimit(1)
                .font(.init(font))
                .offset(x: animate ? 0 : stringWidth + stringHeight * 2)
                .animation(animate ? animation : nullAnimation, value: animate)
                .fixedSize(horizontal: true, vertical: false)
        }
    }

    // MARK: - Fade mask

    @ViewBuilder
    private func fadeMask(leftFade: CGFloat, rightFade: CGFloat) -> some View {
        HStack(spacing: 0) {
            Rectangle().frame(width: 2).opacity(0)

            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0), Color.black]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: leftFade)

            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.black]),
                startPoint: .leading,
                endPoint: .trailing
            )

            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.black.opacity(0)]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: rightFade)

            Rectangle().frame(width: 2).opacity(0)
        }
    }
}

extension MarqueeText {
    func makeCompact(_ compact: Bool = true) -> Self {
        var view = self
        view.isCompact = compact
        return view
    }
}

extension String {
    func widthOfString(usingFont font: Font) -> CGFloat {
        let fontAttributes = [
            NSAttributedString.Key.font: font.toUIFont
        ]

        let size = size(withAttributes: fontAttributes)

        return size.width
    }

    func heightOfString(usingFont font: Font) -> CGFloat {
        let fontAttributes = [
            NSAttributedString.Key.font: font.toUIFont
        ]

        let size = size(withAttributes: fontAttributes)

        return size.height
    }
}
