//
//  ScrubbingProgressView.swift
//  Parra
//
//  Created by Mick MacCallum on 5/23/25.
//

import SwiftUI

private let dragMargin = 12.0

struct ScrubbingProgressView: View {
    // MARK: - Lifecycle

    init(
        progress: Binding<Double>,
        duration: TimeInterval,
        height: CGFloat = 4,
        trackColor: Color = Color.gray.opacity(0.3)
    ) {
        self._progress = progress
        self.duration = duration
        self.height = height
        self.trackColor = trackColor
    }

    // MARK: - Internal

    @Binding var progress: Double
    let height: CGFloat
    let trackColor: Color
    let duration: TimeInterval // Total duration in seconds

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Progress view (always in the same position)
                ZStack(alignment: .leading) {
                    // Track background
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(trackColor)
                        .frame(height: height)

                    // Progress fill
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(theme.palette.primary)
                        .frame(
                            width: max(0, geometry.size.width * progress),
                            height: height
                        )
                }

                if isDragging {
                    VStack(spacing: 0) {
                        componentFactory.buildLabel(
                            text: formatTime(currentTime),
                            localAttributes: .init(
                                text: .default(
                                    with: .caption,
                                    weight: .medium,
                                    design: .monospaced,
                                    color: theme.palette.primaryChipText.toParraColor(),
                                    alignment: .center
                                ),
                                border: .init(
                                    width: 1.0,
                                    color: theme.palette.primaryChipBackground.shade600
                                        .toParraColor()
                                        .opacity(0.1)
                                ),
                                cornerRadius: .md,
                                padding: .md,
                                background: theme.palette.primaryChipBackground
                                    .toParraColor()
                            )
                        )
                        .offset(y: 1.5)

                        Image(systemName: "arrowtriangle.down.fill")
                            .renderingMode(.template)
                            .font(.body)
                            .foregroundColor(
                                theme.palette.primaryChipBackground
                                    .toParraColor()
                            )
                            .offset(
                                x: -0.5 * indicatorOffset(in: geometry)
                            )
                    }
                    .opacity(1.0)
                    .position(
                        x: min(
                            max(dragMargin, geometry.size.width * progress),
                            geometry.size.width - dragMargin
                        ),
                        y: -25
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !isDragging {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                isDragging = true
                            }
                        }

                        let newProgress = min(
                            max(0, value.location.x / geometry.size.width),
                            1.0
                        )
                        progress = newProgress
                    }
                    .onEnded { _ in
                        withAnimation(.easeInOut(duration: 0.15)) {
                            isDragging = false
                        }
                    }
            )
        }
        .frame(height: height)
    }

    func indicatorOffset(in geometry: GeometryProxy) -> Double {
        let offset = geometry.size.width * progress

        if offset <= dragMargin {
            return max(0.0, dragMargin - offset)
        }

        if offset >= geometry.size.width - dragMargin {
            return min(dragMargin, geometry.size.width - dragMargin - offset)
        }

        return 0
    }

    // MARK: - Private

    @State private var isDragging = false

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory

    private var currentTime: TimeInterval {
        return duration * progress
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3_600
        let minutes = Int(time) % 3_600 / 60
        let seconds = Int(time) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}
