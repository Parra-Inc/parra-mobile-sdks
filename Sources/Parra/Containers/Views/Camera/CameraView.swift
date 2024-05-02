//
//  CameraView.swift
//  Parra
//
//  Created by Mick MacCallum on 4/26/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct CameraView: View {
    // MARK: - Lifecycle

    init(
        onComplete: @escaping (UIImage?) -> Void
    ) {
        self.onComplete = onComplete
    }

    // MARK: - Internal

    let onComplete: (UIImage?) -> Void

    @ViewBuilder var renderCamera: some View {
        ViewfinderView(image: $model.viewfinderImage)
    }

    @ViewBuilder var main: some View {
        if let previewImage {
            renderPreview(with: previewImage)
        } else {
            renderCamera
                .task {
                    await model.camera.start()

                    for await photo in model.camera.photoStream {
                        guard let data = photo.fileDataRepresentation() else {
                            continue
                        }

                        guard let image = UIImage(data: data) else {
                            continue
                        }

                        Task { @MainActor in
                            withAnimation {
                                previewImage = image
                            }
                        }
                    }
                }
        }
    }

    var body: some View {
        GeometryReader { geometry in
            main
                .overlay(alignment: .top) {
                    Color.black
                        .opacity(0.75)
                        .frame(
                            height: geometry.size.height * Self
                                .barHeightFactor
                        )
                }
                .overlay(alignment: .bottom) {
                    buttonsView()
                        .background(.black.opacity(0.75))
                        .safeAreaPadding(.bottom)
                }
                .overlay(alignment: .center) {
                    Color.clear
                        .frame(
                            height: geometry.size
                                .height * (1 - (Self.barHeightFactor * 2))
                        )
                        .accessibilityElement()
                        .accessibilityLabel("View Finder")
                        .accessibilityAddTraits([.isImage])
                }
                .background(.black)
        }
        .onAppear {
            UIDevice.current.setValue(
                UIInterfaceOrientation.portrait.rawValue,
                forKey: "orientation"
            ) // Forcing the rotation to portrait

            ParraAppDelegate
                .orientationLock =
                .portrait // And making sure it stays that way
        }
        .onDisappear {
            ParraAppDelegate
                .orientationLock =
                .all // Unlocking the rotation when leaving the view
        }
        .ignoresSafeArea()
        .statusBar(hidden: true)
    }

    @ViewBuilder
    func renderPreview(with image: UIImage) -> some View {
        ViewfinderView(
            image: .constant(Image(uiImage: image))
        )
    }

    // MARK: - Private

    private static let barHeightFactor = 0.15

    @State private var previewImage: UIImage?

    @StateObject private var model = CameraDataModel()
    @State private var captureButtonScale = 1.0

    @ViewBuilder
    private func buttonsView() -> some View {
        HStack {
            if previewImage == nil {
                captureButtonsView()
            } else {
                previewButtonsView()
            }
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .padding(.vertical, 24)
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private func captureButtonsView() -> some View {
        Button("Cancel") {
            onComplete(nil)
        }

        Spacer()

        Button {
            model.camera.takePhoto()
        } label: {
            Label {
                Text("Take Photo")
            } icon: {
                ZStack {
                    Circle()
                        .strokeBorder(.white, lineWidth: 3)
                        .frame(width: 62, height: 62)
                    Circle()
                        .fill(.white)
                        .frame(width: 50, height: 50)
                        .scaleEffect(captureButtonScale)
                        .animation(
                            .linear(duration: 0.1), value: captureButtonScale
                        )
                }
            }
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0)
                .onChanged { pressing in
                    withAnimation {
                        if pressing {
                            captureButtonScale = 0.9
                        } else {
                            captureButtonScale = 1.0
                        }
                    }
                }
        )

        Spacer()

        Button {
            model.camera.switchCaptureDevice()
        } label: {
            Label(
                "Switch Camera",
                systemImage: "arrow.triangle.2.circlepath"
            )
            .font(.system(size: 30))
            .foregroundColor(.white)
        }
    }

    @ViewBuilder
    private func previewButtonsView() -> some View {
        Button("Retake") {
            withAnimation {
                previewImage = nil
            }
        }

        Spacer()

        Button("Use photo") {
            onComplete(previewImage)
        }
    }
}
