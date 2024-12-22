//
//  ReportAlertContentView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/18/24.
//

import SwiftUI

struct ReportAlertContentView: View {
    // MARK: - Internal

    let commentId: String

    var body: some View {
        TextField(text: $reportText) {
            Text("What was wrong with this comment?")
        }

        Button("Cancel", role: .cancel) {}

        Button("Report", role: .destructive) {
            submitReport()
        }
    }

    // MARK: - Private

    @State private var reportText = ""

    @Environment(\.parraAlertManager) private var alertManager
    @Environment(\.parra) private var parra

    private func submitReport() {
        Task { @MainActor in
            do {
                try await parra.parraInternal.api.reportComment(
                    commentId: commentId,
                    reason: reportText.isEmpty ? nil : reportText
                )

                alertManager.showSuccessToast(
                    title: "Report submitted",
                    subtitle: "We'll review your report and take action accordingly."
                )
            } catch {
                alertManager.showErrorToast(
                    title: "Error submitting report",
                    userFacingMessage: "Something went wrong submitting your report.",
                    underlyingError: error
                )
            }
        }
    }
}
