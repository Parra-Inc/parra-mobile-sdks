//
//  RoadmapCell.swift
//  Sample
//
//  Created by Mick MacCallum on 7/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Parra
import SwiftUI

/// This example shows how you can use your own custom logic for determining how
/// and when to present a Parra Feedback Form. The steps to achieve this are:
///
/// 1. Create an `@State` variable to control the presentation state of the
///    roadmap.
/// 2. Pass the `isPresented` binding to the `presentParraRoadmap` modifier.
/// 3. When you're ready to present the roadmap, update the value of
///    `isPresented` to `true`. The roadmap will be fetched and
///    presented automatically.
struct RoadmapCell: View {
    // MARK: - Internal

    var body: some View {
        Button(action: {
            loadRoadmap()
        }) {
            Label(
                title: { Text("Roadmap") },
                icon: {
                    if isLoading {
                        ProgressView()
                    } else {
                        Image(systemName: "map")
                    }
                }
            )
        }
        .disabled(isLoading)
        .presentParraRoadmap(with: $roadmapInfo)
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var roadmapInfo: ParraRoadmapInfo?

    @EnvironmentObject private var themeObserver: ParraThemeObserver

    private func loadRoadmap() {
        isLoading = true

        Task {
            do {
                errorMessage = nil
                roadmapInfo = try await parra.roadmap.fetchRoadmap()
            } catch {
                errorMessage = String(describing: error)
                roadmapInfo = nil

                Logger.error(error)
            }

            isLoading = false
        }
    }
}

#Preview {
    ParraAppPreview {
        RoadmapCell()
    }
}
