//
//  FullScreenGalleryView.swift
//  Parra
//
//  Created by Mick MacCallum on 10/28/24.
//

import SwiftUI

private let maxAllowedScale = 5.0

struct ZoomableContainer<Content: View>: View {
    // MARK: - Lifecycle

    init(
        contentSize: CGSize,
        @ViewBuilder content: () -> Content
    ) {
        self.contentSize = contentSize
        self.content = content()
    }

    // MARK: - Internal

    let contentSize: CGSize
    let content: Content

    var body: some View {
        ZoomableScrollView(
            contentSize: contentSize,
            scale: $currentScale,
            tapLocation: $tapLocation
        ) {
            content
        }
        .onTapGesture(count: 2, perform: doubleTapAction)
        .background(.black)
    }

    func doubleTapAction(location: CGPoint) {
        tapLocation = location
        currentScale = currentScale == 1.0 ? maxAllowedScale / 2 : 1.0
    }

    // MARK: - Fileprivate

    fileprivate struct ZoomableScrollView<ZoomContent: View>: UIViewRepresentable {
        // MARK: - Lifecycle

        init(
            contentSize: CGSize,
            scale: Binding<CGFloat>,
            tapLocation: Binding<CGPoint>,
            @ViewBuilder content: () -> ZoomContent
        ) {
            self.contentSize = contentSize
            _currentScale = scale
            _tapLocation = tapLocation
            self.content = content()
        }

        // MARK: - Internal

        // MARK: - Coordinator

        class Coordinator: NSObject, UIScrollViewDelegate {
            // MARK: - Lifecycle

            init(
                hostingController: UIHostingController<ZoomContent>,
                scale: Binding<CGFloat>
            ) {
                self.hostingController = hostingController
                _currentScale = scale
            }

            // MARK: - Internal

            var hostingController: UIHostingController<ZoomContent>
            @Binding var currentScale: CGFloat

            func viewForZooming(in scrollView: UIScrollView) -> UIView? {
                return hostingController.view
            }

            func scrollViewDidEndZooming(
                _ scrollView: UIScrollView,
                with view: UIView?,
                atScale scale: CGFloat
            ) {
                currentScale = scale
            }
        }

        let contentSize: CGSize

        func makeUIView(context: Context) -> UIScrollView {
            // Setup the UIScrollView
            let scrollView = UIScrollView()

            scrollView.backgroundColor = .black
            scrollView.delegate = context.coordinator // for viewForZooming(in:)
            scrollView.maximumZoomScale = maxAllowedScale
            scrollView.minimumZoomScale = 1
            scrollView.bouncesZoom = true
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = false
            scrollView.clipsToBounds = false
            scrollView.translatesAutoresizingMaskIntoConstraints = true
            scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            // Create a UIHostingController to hold our SwiftUI content
            let hostedView = context.coordinator.hostingController.view!

            hostedView.translatesAutoresizingMaskIntoConstraints = true
            hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            hostedView.frame = scrollView.bounds
            hostedView.backgroundColor = .black
            scrollView.addSubview(hostedView)

            return scrollView
        }

        func makeCoordinator() -> Coordinator {
            return Coordinator(
                hostingController: UIHostingController(rootView: content),
                scale: $currentScale
            )
        }

        func updateUIView(_ uiView: UIScrollView, context: Context) {
            // Update the hosting controller's SwiftUI content
            context.coordinator.hostingController.rootView = content

            if uiView.zoomScale > uiView.minimumZoomScale { // Scale out
                uiView.setZoomScale(currentScale, animated: true)
            } else if tapLocation != .zero { // Scale in to a specific point
                uiView.zoom(
                    to: zoomRect(
                        for: uiView,
                        scale: uiView.maximumZoomScale,
                        center: tapLocation,
                        context: context
                    ),
                    animated: true
                )
                // Reset the location to prevent scaling to it in case of a
                // negative scale (manual pinch). Use the main thread to
                // prevent unexpected behavior
                DispatchQueue.main.async { tapLocation = .zero }
            }

            assert(
                context.coordinator.hostingController.view.superview == uiView
            )
        }

        // MARK: - Utils

        func zoomRect(
            for scrollView: UIScrollView,
            scale: CGFloat,
            center: CGPoint,
            context: Context
        ) -> CGRect {
            let scrollViewSize = scrollView.bounds.size
            let hostedView = context.coordinator.hostingController.view!

            let width = min(
                scrollViewSize.width / scale,
                hostedView.bounds.width
            )
            let height = min(
                scrollViewSize.height / scale,
                hostedView.bounds.height
            )
            let x = center.x - (width / 2.0)
            let y = center.y - (height / 2.0)

            return CGRect(x: x, y: y, width: width, height: height)
        }

        // MARK: - Private

        private var content: ZoomContent
        @Binding private var currentScale: CGFloat
        @Binding private var tapLocation: CGPoint
    }

    // MARK: - Private

    @State private var currentScale: CGFloat = 1.0
    @State private var tapLocation: CGPoint = .zero
}

struct FullScreenGalleryView: View {
    // MARK: - Internal

    let photos: [ParraImageAssetStub]
    @Binding var selectedPhoto: ParraImageAssetStub?
    @Binding var isShowingFullScreen: Bool

    var body: some View {
        TabView(selection: $selectedPhoto) {
            photoViews
        }
        .tabViewStyle(.page)
        .ignoresSafeArea()
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .overlay(alignment: .topTrailing) {
            Button {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    isShowingFullScreen = false
                    selectedPhoto = nil
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
            }
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory

    @ViewBuilder private var photoViews: some View {
        ForEach(photos) { photo in
            ZoomableContainer(contentSize: photo.size) {
                componentFactory.buildAsyncImage(
                    content: ParraAsyncImageContent(
                        url: photo.url,
                        originalSize: photo.size
                    )
                )
            }
            .tag(photo as ParraImageAssetStub?)
        }
    }
}
