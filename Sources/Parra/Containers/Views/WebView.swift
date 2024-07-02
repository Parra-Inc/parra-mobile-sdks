//
//  WebView.swift
//  Parra
//
//  Created by Mick MacCallum on 7/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    // MARK: - Lifecycle

    init(url: URL) {
        self.url = url

        self.webView = WKWebView(frame: .zero)
    }

    // MARK: - Internal

    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return webView
    }

    func updateUIView(
        _ uiView: WKWebView,
        context: Context
    ) {
        let request = URLRequest(
            url: url
        )

        webView.load(
            request
        )
    }

    // MARK: - Private

    private let webView: WKWebView
}

#Preview {
    WebView(url: URL(string: "https://parra.io")!)
}
