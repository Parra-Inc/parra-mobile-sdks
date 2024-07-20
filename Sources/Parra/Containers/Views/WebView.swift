//
//  WebView.swift
//  Parra
//
//  Created by Mick MacCallum on 7/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI
import WebKit

struct WebView: View {
    // MARK: - Lifecycle

    init(url: URL) {
        self.url = url
    }

    // MARK: - Internal

    var themedUrl: URL {
        let theme = colorScheme == .light ? "light" : "dark"

        return url.appending(
            queryItems: [
                URLQueryItem(name: "theme", value: theme)
            ]
        )
    }

    var body: some View {
        _WebView(
            url: themedUrl,
            isLoading: $isLoading,
            errorMessage: $errorMessage
        )
        .overlay {
            if let errorMessage {
                Text(errorMessage)
            } else if isLoading {
                ProgressView()
            } else {
                EmptyView()
            }
        }
    }

    // MARK: - Private

    private let url: URL

    @State private var isLoading: Bool = true
    @State private var errorMessage: String?

    @Environment(\.colorScheme) private var colorScheme
}

struct _WebView: UIViewRepresentable {
    // MARK: - Lifecycle

    init(
        url: URL,
        isLoading: Binding<Bool>,
        errorMessage: Binding<String?>
    ) {
        Logger.trace("Preparing web view", [
            "url": url.absoluteString
        ])

        self.url = url
        self._isLoading = isLoading
        self._errorMessage = errorMessage
    }

    // MARK: - Internal

    class Coordinator: NSObject, WKNavigationDelegate {
        // MARK: - Lifecycle

        init(_ parent: _WebView) {
            self.parent = parent
        }

        // MARK: - Internal

        var parent: _WebView

        func webView(
            _ webView: WKWebView,
            didStartProvisionalNavigation navigation: WKNavigation!
        ) {
            parent.isLoading = true
            parent.errorMessage = nil

            Logger.trace("Web view did start navigation")
        }

        func webView(
            _ webView: WKWebView,
            didFinish navigation: WKNavigation!
        ) {
            parent.isLoading = false

            Logger.trace("Web view did finish navigation")
        }

        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation!,
            withError error: Error
        ) {
            parent.isLoading = false
            parent.errorMessage = error.localizedDescription

            Logger.trace("Web view did fail navigation")
        }
    }

    let url: URL
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator

        let request = URLRequest(url: url)
        webView.load(request)

        return webView
    }

    func updateUIView(
        _ uiView: WKWebView,
        context: Context
    ) {}
}

#Preview {
    WebView(url: URL(string: "https://parra.io")!)
}
