//
//  GifImageView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/11/24.
//

import SwiftUI
import UIKit
import WebKit

struct GifImageView: UIViewRepresentable {
    // MARK: - Lifecycle

    init(url: URL) {
        self.url = url
    }

    // MARK: - Internal

    func makeUIView(context: Context) -> WKWebView {
        let webview = WKWebView()

        webview.allowsLinkPreview = false
        webview.allowsBackForwardNavigationGestures = false

        webview.load(URLRequest(url: url))

        return webview
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.reload()
    }

    // MARK: - Private

    private let url: URL
}

#Preview {
    GifImageView(
        url: URL(
            string:
            "https://i.giphy.com/media/v1.Y2lkPTc5MGI3NjExZ29pdGtnN2hoNTVwa3prM2ZjZzRrNXptOW5tc3pmMGJ5MzVybm9kNiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/UTSxCoPWRbhD3Xn4rt/giphy.gif"
        )!
    )
}
