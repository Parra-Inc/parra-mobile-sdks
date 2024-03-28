//
//  RecentLogViewer.swift
//  Parra
//
//  Created by Mick MacCallum on 3/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

final class DebugLogStore: ObservableObject {
    struct UniqueLog: Identifiable {
        let id: String
        let message: String
        let timestamp: String
    }

    static let shared = DebugLogStore()

    @Published var lines: [UniqueLog] = []

    @MainActor
    func write(_ message: String) {
        if lines.count > 500 {
            lines = Array(lines.prefix(500))
        }

        let timestamp = ParraInternal.Constants.Formatters.iso8601Formatter
            .string(
                from: .now
            )

        let log = UniqueLog(
            id: UUID().uuidString,
            message: message,
            timestamp: timestamp
        )

        lines.append(log)
    }
}

private let palette = ParraTheme.default.palette

struct Log: View {
    let log: DebugLogStore.UniqueLog

    var body: some View {
        VStack(alignment: .leading) {
            Text(log.timestamp)
                .font(.caption)
                .foregroundStyle(palette.secondaryText.toParraColor())

            Text(log.message)
                .font(.footnote)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(palette.secondaryBackground)
        .applyCornerRadii(size: .md, from: .default)
    }
}

struct RecentLogViewer: View {
    // MARK: - Internal

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(debugLogStore.lines) { line in
                    Log(log: line)
                }
            }
        }
        .contentMargins(20, for: .scrollContent)
        .background(palette.primaryBackground)
    }

    // MARK: - Private

    @StateObject private var debugLogStore = DebugLogStore.shared
}

#Preview {
    RecentLogViewer()
}
