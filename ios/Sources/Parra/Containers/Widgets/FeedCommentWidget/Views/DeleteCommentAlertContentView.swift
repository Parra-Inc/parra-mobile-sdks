//
//  DeleteCommentAlertContentView.swift
//  Parra
//
//  Created by Mick MacCallum on 3/1/25.
//

import SwiftUI

struct DeleteCommentAlertContentView: View {
    // MARK: - Internal

    var commentId: String
    var onConfirm: () -> Void

    var body: some View {
        Button("Cancel", role: .cancel) {}

        Button("Delete", role: .destructive) {
            onConfirm()
            dismiss()
        }
    }

    // MARK: - Private

    @Environment(\.dismiss) private var dismiss
}
