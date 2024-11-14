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

    init(
        url: URL,
        isLoading: Binding<Bool>
    ) {
        self.url = url
        self._isLoading = isLoading
    }

    // MARK: - Internal

    @Binding var isLoading: Bool

    var theme: String {
        return colorScheme == .light ? "light" : "dark"
    }

    var themedUrl: URL {
        return url.appending(
            queryItems: [
                URLQueryItem(name: "theme", value: theme)
            ]
        )
    }

    var body: some View {
        let backgroundColor = parraTheme.palette.primaryBackground

        _WebView(
            url: themedUrl,
            theme: theme,
            backgroundColor: backgroundColor,
            isLoading: $isLoading,
            errorMessage: $errorMessage
        )
        .overlay {
            if let errorMessage {
                Text(errorMessage)
            } else {
                EmptyView()
            }
        }
    }

    // MARK: - Private

    private let url: URL

    @State private var errorMessage: String?

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.parraTheme) private var parraTheme
}

struct _WebView: UIViewRepresentable {
    // MARK: - Lifecycle

    init(
        url: URL,
        theme: String,
        backgroundColor: Color,
        isLoading: Binding<Bool>,
        errorMessage: Binding<String?>
    ) {
        Logger.trace("Preparing web view", [
            "url": url.absoluteString,
            "theme": theme
        ])

        self.url = url
        self.theme = theme
        self.backgroundColor = UIColor(backgroundColor)
        self._isLoading = isLoading
        self._errorMessage = errorMessage
    }

    // MARK: - Internal

    class Coordinator: NSObject, WKNavigationDelegate {
        // MARK: - Lifecycle

        init(
            _ parent: _WebView,
            _ theme: String
        ) {
            self.parent = parent
            self.theme = theme
        }

        // MARK: - Internal

        var parent: _WebView
        let theme: String

        func webView(
            _ webView: WKWebView,
            didStartProvisionalNavigation navigation: WKNavigation!
        ) {
            withAnimation {
                parent.isLoading = true
                parent.errorMessage = nil
            }

            Logger.trace("Web view did start navigation")
        }

        func webView(
            _ webView: WKWebView,
            didFinish navigation: WKNavigation!
        ) {
            webView.evaluateJavaScript(
                "document.documentElement.setAttribute('data-theme', '\(theme)')",
                completionHandler: nil
            )

            withAnimation {
                parent.isLoading = false
            }

            Logger.trace("Web view did finish navigation")
        }

        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation!,
            withError error: Error
        ) {
            withAnimation {
                parent.errorMessage = error.localizedDescription
                parent.isLoading = false
            }

            Logger.trace("Web view did fail navigation")
        }
    }

    let url: URL
    let theme: String
    let backgroundColor: UIColor

    @Binding var isLoading: Bool
    @Binding var errorMessage: String?

    func makeCoordinator() -> Coordinator {
        Coordinator(self, theme)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.backgroundColor = backgroundColor

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
    WebView(url: URL(string: "https://parra.io")!, isLoading: .constant(false))
}
