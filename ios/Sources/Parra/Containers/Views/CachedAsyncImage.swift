//    https://github.com/lorenzofiamingo/swiftui-cached-async-image/tree/main
//
//
//    MIT License
//
//    Copyright (c) 2021 Lorenzo Fiamingo
//
//    Permission is hereby granted, free of charge, to any person obtaining a
//    copy of this software and associated documentation files (the "Software"),
//    to deal in the Software without restriction, including without limitation
//    the rights to use, copy, modify, merge, publish, distribute, sublicense,
//    and/or sell copies of the Software, and to permit persons to whom the
//    Software is furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in
//    all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//    THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//    DEALINGS IN THE SOFTWARE.
//

//
//  Created by Lorenzo Fiamingo on 04/11/20.
//

import SwiftUI

private let logger = Logger(category: "Async Image")

public enum CachedAsyncImagePhase: Sendable {
    /// No image is loaded.
    case empty

    /// An image succesfully loaded.
    case success(Image, CGSize)

    /// An image failed to load with an error.
    case failure(any Error)
}

/// A view that asynchronously loads, cache and displays an image.
///
/// This view uses a custom default
/// <doc://com.apple.documentation/documentation/Foundation/URLSession>
/// instance to load an image from the specified URL, and then display it.
/// For example, you can display an icon that's stored on a server:
///
///     CachedAsyncImage(url: URL(string: "https://example.com/icon.png"))
///         .frame(width: 200, height: 200)
///
/// Until the image loads, the view displays a standard placeholder that
/// fills the available space. After the load completes successfully, the view
/// updates to display the image. In the example above, the icon is smaller
/// than the frame, and so appears smaller than the placeholder.
///
/// ![A diagram that shows a grey box on the left, the SwiftUI icon on the
/// right, and an arrow pointing from the first to the second. The icon
/// is about half the size of the grey box.](AsyncImage-1)
///
/// You can specify a custom placeholder using
/// ``init(url:urlCache:scale:content:placeholder:)``. With this initializer, you can
/// also use the `content` parameter to manipulate the loaded image.
/// For example, you can add a modifier to make the loaded image resizable:
///
///     CachedAsyncImage(url: URL(string: "https://example.com/icon.png")) { image in
///         image.resizable()
///     } placeholder: {
///         ProgressView()
///     }
///     .frame(width: 50, height: 50)
///
/// For this example, SwiftUI shows a ``ProgressView`` first, and then the
/// image scaled to fit in the specified frame:
///
/// ![A diagram that shows a progress view on the left, the SwiftUI icon on the
/// right, and an arrow pointing from the first to the second.](AsyncImage-2)
///
/// > Important: You can't apply image-specific modifiers, like
/// ``Image/resizable(capInsets:resizingMode:)``, directly to a `CachedAsyncImage`.
/// Instead, apply them to the ``Image`` instance that your `content`
/// closure gets when defining the view's appearance.
///
/// To gain more control over the loading process, use the
/// ``init(url:urlCache:scale:transaction:content:)`` initializer, which takes a
/// `content` closure that receives an ``AsyncImagePhase`` to indicate
/// the state of the loading operation. Return a view that's appropriate
/// for the current phase:
///
///     CachedAsyncImage(url: URL(string: "https://example.com/icon.png")) { phase in
///         if let image = phase.image {
///             image // Displays the loaded image.
///         } else if phase.error != nil {
///             Color.red // Indicates an error.
///         } else {
///             Color.blue // Acts as a placeholder.
///         }
///     }
///
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct CachedAsyncImage<Content>: View where Content: View {
    // MARK: - Lifecycle

    /// Loads and displays an image from the specified URL.
    ///
    /// Until the image loads, SwiftUI displays a default placeholder. When
    /// the load operation completes successfully, SwiftUI updates the
    /// view to show the loaded image. If the operation fails, SwiftUI
    /// continues to display the placeholder. The following example loads
    /// and displays an icon from an example server:
    ///
    ///     CachedAsyncImage(url: URL(string: "https://example.com/icon.png"))
    ///
    /// If you want to customize the placeholder or apply image-specific
    /// modifiers --- like ``Image/resizable(capInsets:resizingMode:)`` ---
    /// to the loaded image, use the ``init(url:scale:content:placeholder:)``
    /// initializer instead.
    ///
    /// - Parameters:
    ///   - url: The URL of the image to display.
    ///   - urlCache: The URL cache for providing cached responses to requests within the session.
    ///   - scale: The scale to use for the image. The default is `1`. Set a
    ///     different value when loading images designed for higher resolution
    ///     displays. For example, set a value of `2` for an image that you
    ///     would name with the `@2x` suffix if stored in a file on disk.
    init(
        url: URL?,
        urlCache: URLCache = .shared,
        scale: CGFloat = 1
    ) where Content == Image {
        let urlRequest: URLRequest? = if let url {
            URLRequest(url: url)
        } else {
            nil
        }

        self.init(
            urlRequest: urlRequest,
            urlCache: urlCache,
            scale: scale
        )
    }

    /// Loads and displays an image from the specified URL.
    ///
    /// Until the image loads, SwiftUI displays a default placeholder. When
    /// the load operation completes successfully, SwiftUI updates the
    /// view to show the loaded image. If the operation fails, SwiftUI
    /// continues to display the placeholder. The following example loads
    /// and displays an icon from an example server:
    ///
    ///     CachedAsyncImage(url: URL(string: "https://example.com/icon.png"))
    ///
    /// If you want to customize the placeholder or apply image-specific
    /// modifiers --- like ``Image/resizable(capInsets:resizingMode:)`` ---
    /// to the loaded image, use the ``init(url:scale:content:placeholder:)``
    /// initializer instead.
    ///
    /// - Parameters:
    ///   - urlRequest: The URL request of the image to display.
    ///   - urlCache: The URL cache for providing cached responses to requests within the session.
    ///   - scale: The scale to use for the image. The default is `1`. Set a
    ///     different value when loading images designed for higher resolution
    ///     displays. For example, set a value of `2` for an image that you
    ///     would name with the `@2x` suffix if stored in a file on disk.
    init(
        urlRequest: URLRequest?,
        urlCache: URLCache = .shared,
        scale: CGFloat = 1
    ) where Content == Image {
        self
            .init(
                urlRequest: urlRequest,
                urlCache: urlCache,
                scale: scale
            ) { phase in
                return switch phase {
                case .success(let image, _):
                    image
                case .failure, .empty:
                    Image(uiImage: .init())
                }
            }
    }

    /// Loads and displays a modifiable image from the specified URL using
    /// a custom placeholder until the image loads.
    ///
    /// Until the image loads, SwiftUI displays the placeholder view that
    /// you specify. When the load operation completes successfully, SwiftUI
    /// updates the view to show content that you specify, which you
    /// create using the loaded image. For example, you can show a green
    /// placeholder, followed by a tiled version of the loaded image:
    ///
    ///     CachedAsyncImage(url: URL(string: "https://example.com/icon.png")) { image in
    ///         image.resizable(resizingMode: .tile)
    ///     } placeholder: {
    ///         Color.green
    ///     }
    ///
    /// If the load operation fails, SwiftUI continues to display the
    /// placeholder. To be able to display a different view on a load error,
    /// use the ``init(url:scale:transaction:content:)`` initializer instead.
    ///
    /// - Parameters:
    ///   - url: The URL of the image to display.
    ///   - urlCache: The URL cache for providing cached responses to requests within the session.
    ///   - scale: The scale to use for the image. The default is `1`. Set a
    ///     different value when loading images designed for higher resolution
    ///     displays. For example, set a value of `2` for an image that you
    ///     would name with the `@2x` suffix if stored in a file on disk.
    ///   - content: A closure that takes the loaded image as an input, and
    ///     returns the view to show. You can return the image directly, or
    ///     modify it as needed before returning it.
    ///   - placeholder: A closure that returns the view to show until the
    ///     load operation completes successfully.
    init<I, P>(
        url: URL?,
        urlCache: URLCache = .shared,
        scale: CGFloat = 1,
        @ViewBuilder content: @escaping (Image, CGSize) -> I,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<I, P>, I: View, P: View {
        let urlRequest: URLRequest? = if let url {
            URLRequest(url: url)
        } else {
            nil
        }

        self.init(
            urlRequest: urlRequest,
            urlCache: urlCache,
            scale: scale,
            content: content,
            placeholder: placeholder
        )
    }

    /// Loads and displays a modifiable image from the specified URL using
    /// a custom placeholder until the image loads.
    ///
    /// Until the image loads, SwiftUI displays the placeholder view that
    /// you specify. When the load operation completes successfully, SwiftUI
    /// updates the view to show content that you specify, which you
    /// create using the loaded image. For example, you can show a green
    /// placeholder, followed by a tiled version of the loaded image:
    ///
    ///     CachedAsyncImage(url: URL(string: "https://example.com/icon.png")) { image in
    ///         image.resizable(resizingMode: .tile)
    ///     } placeholder: {
    ///         Color.green
    ///     }
    ///
    /// If the load operation fails, SwiftUI continues to display the
    /// placeholder. To be able to display a different view on a load error,
    /// use the ``init(url:scale:transaction:content:)`` initializer instead.
    ///
    /// - Parameters:
    ///   - urlRequest: The URL request of the image to display.
    ///   - urlCache: The URL cache for providing cached responses to requests within the session.
    ///   - scale: The scale to use for the image. The default is `1`. Set a
    ///     different value when loading images designed for higher resolution
    ///     displays. For example, set a value of `2` for an image that you
    ///     would name with the `@2x` suffix if stored in a file on disk.
    ///   - content: A closure that takes the loaded image as an input, and
    ///     returns the view to show. You can return the image directly, or
    ///     modify it as needed before returning it.
    ///   - placeholder: A closure that returns the view to show until the
    ///     load operation completes successfully.
    init<I, P>(
        urlRequest: URLRequest?,
        urlCache: URLCache = .shared,
        scale: CGFloat = 1,
        @ViewBuilder content: @escaping (Image, CGSize) -> I,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<I, P>, I: View, P: View {
        self
            .init(
                urlRequest: urlRequest,
                urlCache: urlCache,
                scale: scale
            ) { phase in
                if case .success(let image, let size) = phase {
                    content(image, size)
                } else {
                    placeholder()
                }
            }
    }

    /// Loads and displays a modifiable image from the specified URL in phases.
    ///
    /// If you set the asynchronous image's URL to `nil`, or after you set the
    /// URL to a value but before the load operation completes, the phase is
    /// ``AsyncImagePhase/empty``. After the operation completes, the phase
    /// becomes either ``AsyncImagePhase/failure(_:)`` or
    /// ``AsyncImagePhase/success(_:)``. In the first case, the phase's
    /// ``AsyncImagePhase/error`` value indicates the reason for failure.
    /// In the second case, the phase's ``AsyncImagePhase/image`` property
    /// contains the loaded image. Use the phase to drive the output of the
    /// `content` closure, which defines the view's appearance:
    ///
    ///     CachedAsyncImage(url: URL(string: "https://example.com/icon.png")) { phase in
    ///         if let image = phase.image {
    ///             image // Displays the loaded image.
    ///         } else if phase.error != nil {
    ///             Color.red // Indicates an error.
    ///         } else {
    ///             Color.blue // Acts as a placeholder.
    ///         }
    ///     }
    ///
    /// To add transitions when you change the URL, apply an identifier to the
    /// ``CachedAsyncImage``.
    ///
    /// - Parameters:
    ///   - url: The URL of the image to display.
    ///   - urlCache: The URL cache for providing cached responses to requests within the session.
    ///   - scale: The scale to use for the image. The default is `1`. Set a
    ///     different value when loading images designed for higher resolution
    ///     displays. For example, set a value of `2` for an image that you
    ///     would name with the `@2x` suffix if stored in a file on disk.
    ///   - transaction: The transaction to use when the phase changes.
    ///   - content: A closure that takes the load phase as an input, and
    ///     returns the view to display for the specified phase.
    init(
        url: URL?,
        urlCache: URLCache = .shared,
        scale: CGFloat = 1,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (CachedAsyncImagePhase) -> Content
    ) {
        let urlRequest: URLRequest? = if let url {
            URLRequest(url: url)
        } else {
            nil
        }

        self.init(
            urlRequest: urlRequest,
            urlCache: urlCache,
            scale: scale,
            transaction: transaction,
            content: content
        )
    }

    /// Loads and displays a modifiable image from the specified URL in phases.
    ///
    /// If you set the asynchronous image's URL to `nil`, or after you set the
    /// URL to a value but before the load operation completes, the phase is
    /// ``AsyncImagePhase/empty``. After the operation completes, the phase
    /// becomes either ``AsyncImagePhase/failure(_:)`` or
    /// ``AsyncImagePhase/success(_:)``. In the first case, the phase's
    /// ``AsyncImagePhase/error`` value indicates the reason for failure.
    /// In the second case, the phase's ``AsyncImagePhase/image`` property
    /// contains the loaded image. Use the phase to drive the output of the
    /// `content` closure, which defines the view's appearance:
    ///
    ///     CachedAsyncImage(url: URL(string: "https://example.com/icon.png")) { phase in
    ///         if let image = phase.image {
    ///             image // Displays the loaded image.
    ///         } else if phase.error != nil {
    ///             Color.red // Indicates an error.
    ///         } else {
    ///             Color.blue // Acts as a placeholder.
    ///         }
    ///     }
    ///
    /// To add transitions when you change the URL, apply an identifier to the
    /// ``CachedAsyncImage``.
    ///
    /// - Parameters:
    ///   - urlRequest: The URL request of the image to display.
    ///   - urlCache: The URL cache for providing cached responses to requests within the session.
    ///   - scale: The scale to use for the image. The default is `1`. Set a
    ///     different value when loading images designed for higher resolution
    ///     displays. For example, set a value of `2` for an image that you
    ///     would name with the `@2x` suffix if stored in a file on disk.
    ///   - transaction: The transaction to use when the phase changes.
    ///   - content: A closure that takes the load phase as an input, and
    ///     returns the view to display for the specified phase.
    init(
        urlRequest: URLRequest?,
        urlCache: URLCache = .shared,
        scale: CGFloat = 1,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (CachedAsyncImagePhase) -> Content
    ) {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = urlCache
        self.urlRequest = urlRequest
        self.urlSession = URLSession(configuration: configuration)
        self.scale = scale
        self.transaction = transaction
        self.content = content

        do {
            if let urlRequest, let (image, size) = try cachedImage(
                from: urlRequest,
                cache: urlCache
            ) {
                self._phase = State(wrappedValue: .success(image, size))
            }
        } catch {
            self._phase = State(wrappedValue: .failure(error))
        }
    }

    // MARK: - Internal

    var body: some View {
        content(phase).task(
            id: urlRequest,
            priority: .userInitiated
        ) {
            guard let urlRequest, case .empty = phase else {
                return
            }

            do {
                logger.trace("preparing to download image", [
                    "imageUrl": urlRequest.url?.absoluteString ?? "nil"
                ])

                let (image, size, metrics) = try await remoteImage(
                    from: urlRequest,
                    session: urlSession
                )

                logger.trace("image downloaded successfully", [
                    "imageUrl": urlRequest.url?.absoluteString ?? "nil"
                ])

                if let metrics, metrics.transactionMetrics.last?
                    .resourceFetchType == .localCache
                {
                    // WARNING: This does not behave well when the url is changed with another
                    phase = .success(image, size)
                } else {
                    withAnimation(transaction.animation) {
                        phase = .success(image, size)
                    }
                }
            } catch {
                if !Task.isCancelled {
                    logger.warn("image download failed", error, [
                        "imageUrl": urlRequest.url?.absoluteString ?? "nil"
                    ])

                    withAnimation(transaction.animation) {
                        phase = .failure(error)
                    }
                }
            }
        }
    }

    // MARK: - Private

    @State private var phase: CachedAsyncImagePhase = .empty

    private let urlRequest: URLRequest?

    private let urlSession: URLSession

    private let scale: CGFloat

    private let transaction: Transaction

    private let content: (CachedAsyncImagePhase) -> Content
}

// MARK: - AsyncImage.LoadingError

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private extension AsyncImage {
    struct LoadingError: Error {}
}

// MARK: - Helpers

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private extension CachedAsyncImage {
    private func remoteImage(
        from request: URLRequest,
        session: URLSession
    ) async throws -> (Image, CGSize, URLSessionTaskMetrics?) {
        let (data, _, metrics) = try await session.data(for: request)

        if let metrics, metrics.redirectCount > 0,
           let lastResponse = metrics.transactionMetrics.last?.response
        {
            let requests = metrics.transactionMetrics.map(\.request)

            if let cache = session.configuration.urlCache {
                for request in requests {
                    cache.removeCachedResponse(for: request)
                }

                let lastCachedResponse = CachedURLResponse(
                    response: lastResponse,
                    data: data
                )

                cache.storeCachedResponse(
                    lastCachedResponse,
                    for: request
                )
            }
        }

        let (image, size) = try self.image(from: data)

        return (image, size, metrics)
    }

    private func cachedImage(
        from request: URLRequest,
        cache: URLCache
    ) throws -> (Image, CGSize)? {
        guard let cachedResponse = cache.cachedResponse(for: request) else {
            logger.trace("Cache miss", [
                "imageUrl": request.url?.absoluteString ?? "nil"
            ])

            return nil
        }

        logger.trace("Cache hit", [
            "imageUrl": request.url?.absoluteString ?? "nil"
        ])

        return try image(from: cachedResponse.data)
    }

    private func image(from data: Data) throws -> (Image, CGSize) {
        if let uiImage = UIImage(data: data, scale: scale) {
            return (Image(uiImage: uiImage), uiImage.size)
        } else {
            throw AsyncImage<Content>.LoadingError()
        }
    }
}

// MARK: - AsyncImageURLSession

private class URLSessionTaskController: NSObject, URLSessionTaskDelegate {
    var metrics: URLSessionTaskMetrics?

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didFinishCollecting metrics: URLSessionTaskMetrics
    ) {
        self.metrics = metrics
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private extension URLSession {
    func data(
        for request: URLRequest
    ) async throws -> (Data, URLResponse, URLSessionTaskMetrics?) {
        let controller = URLSessionTaskController()

        var request = request
        request.setValue(
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            forHTTPHeaderField: "User-Agent"
        )
//        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8", forHTTPHeaderField: "Accept")
//        request.setValue("en-US,en;q=0.5", forHTTPHeaderField: "Accept-Language")
//        request.setValue("keep-alive", forHTTPHeaderField: "Connection")

        // Some sites may also require referrer
//        request.setValue("https://example.com", forHTTPHeaderField: "Referer")

        let (data, response) = try await data(
            for: request,
            delegate: controller
        )

        return (data, response, controller.metrics)
    }
}
