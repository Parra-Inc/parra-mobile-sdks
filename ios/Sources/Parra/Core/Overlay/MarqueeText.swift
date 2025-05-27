//
//  MarqueeText.swift
//  Parra
//
//  Created by Mick MacCallum on 5/23/25.
//

import SwiftUI

private let logger = Logger()

struct MarqueeText: View {
    // MARK: - Lifecycle

    init(
        text: String,
        animationEnabled: Binding<Bool>,
        speed: Double = 50,
        spacing: CGFloat = 50,
        pauseDuration: Double = 2.0,
        startDelay: Double = 2.0,
        fadeWidth: CGFloat = 20
    ) {
        self.text = text
        self._animationEnabled = animationEnabled
        self.speed = speed
        self.spacing = spacing
        self.pauseDuration = pauseDuration
        self.startDelay = startDelay
        self.fadeWidth = fadeWidth
    }

    // MARK: - Internal

    let text: String
    let speed: Double
    let spacing: CGFloat
    let pauseDuration: Double // Pause at start/end
    let startDelay: Double
    let fadeWidth: CGFloat // Width of the fade effect

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: spacing) {
                componentFactory.buildLabel(
                    text: text,
                    localAttributes: .default(with: .body, weight: .medium)
                )
                .fixedSize()
                .background(
                    GeometryReader { textGeometry in
                        Color.clear
                            .onAppear {
                                textWidth = textGeometry.size.width
                            }
                    }
                )

                componentFactory.buildLabel(
                    text: text,
                    localAttributes: .default(with: .body, weight: .medium)
                )
                .fixedSize()
            }
            .offset(x: animate ? -(textWidth + spacing) : 0)
            .onAppear {
                containerWidth = geometry.size.width

                stopAnimation()

                if textWidth > containerWidth {
                    DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
                        startTimerBasedAnimation()
                    }
                }
            }
            .onChange(of: geometry.size.width) { _, newWidth in
                if containerWidth == newWidth {
                    return
                }

                containerWidth = newWidth

                if textWidth > containerWidth && animationTimer == nil {
                    stopAnimation()

                    DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
                        if animationEnabled {
                            startTimerBasedAnimation()
                        }
                    }
                }
            }
            .onDisappear {
                stopAnimation()
            }
            .frame(
                maxHeight: .infinity
            )
            .clipped()
        }
        .mask(
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: .clear, location: 0.0),
                    .init(color: .black, location: animate ? 0.0 : 0.04),
                    .init(color: .black, location: 0.96),
                    .init(color: .clear, location: 1.0)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipped()
    }

    // MARK: - Private

    @Binding private var animationEnabled: Bool

    @State private var animate = false
    @State private var textWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 0
    @State private var animationTimer: Timer?
    @State private var animationStartCount = 0
    @State private var animationCompletionCount = 0

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory

    private var animationDuration: Double {
        (textWidth + spacing) / speed
    }

    private func startTimerBasedAnimation() {
        guard textWidth > containerWidth else {
            return
        }

        // Perform the first animation immediately
        performAnimation()

        // Set up timer for subsequent animations
        animationTimer = Timer.scheduledTimer(
            withTimeInterval: animationDuration + pauseDuration,
            repeats: true
        ) { _ in
            performAnimation()
        }
    }

    private func performAnimation() {
        // Notify animation start
        animationStartCount += 1
        logger.trace("animation started: \(animationStartCount)")

        // Reset to start position without animation
        animate = false

        // Start the animation to end position
        withAnimation(.linear(duration: animationDuration)) {
            animate = true
        }

        // Schedule completion notification
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            animationCompletionCount += 1
            logger.trace("animation completed: \(animationCompletionCount)")
        }
    }

    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
        animate = false
    }
}

#Preview {
    ParraAppPreview {
        MarqueeText(
            text: "This is a long title of a podcast!",
            animationEnabled: .constant(true)
        )
    }
}
