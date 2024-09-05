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

    @State var permissionGranted: Bool? = nil

    let onComplete: (UIImage?) -> Void

    var body: some View {
        primaryContent
            .onAppear {
                UIDevice.current.setValue(
                    UIInterfaceOrientation.portrait.rawValue,
                    forKey: "orientation"
                ) // Forcing the rotation to portrait

                ParraOrientation
                    .orientationLock =
                    .portrait // And making sure it stays that way
            }
            .onDisappear {
                ParraOrientation
                    .orientationLock =
                    .all // Unlocking the rotation when leaving the view
            }
            .ignoresSafeArea()
            .statusBar(hidden: true)
            .task {
                permissionGranted = await model.camera.checkAuthorization()

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
            .onChange(of: permissionGranted) { _, newValue in
                Task {
                    if newValue == true {
                        await model.camera.start()
                    } else if newValue == false {
                        model.camera.stop()
                    }
                }
            }
    }

    @ViewBuilder var renderPermissionView: some View {
        CameraPermissionDeniedView()
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
    @State private var model = CameraDataModel()
    @State private var captureButtonScale = 1.0

    @ViewBuilder private var renderCamera: some View {
        ViewfinderView(image: $model.viewfinderImage)
    }

    @ViewBuilder private var main: some View {
        if let previewImage {
            renderPreview(with: previewImage)
        } else {
            renderCamera
        }
    }

    @ViewBuilder private var primaryContent: some View {
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
                    if permissionGranted == true {
                        Color.clear
                            .frame(
                                height: geometry.size
                                    .height * (1 - (Self.barHeightFactor * 2))
                            )
                            .accessibilityElement()
                            .accessibilityLabel("View Finder")
                            .accessibilityAddTraits([.isImage])
                    } else if permissionGranted == false {
                        renderPermissionView
                            .padding()
                    } else {
                        EmptyView()
                    }
                }
                .background(.black)
        }
    }

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
        .foregroundStyle(.white)

        Spacer()

        if permissionGranted == true {
            Button {
                model.camera.takePhoto()
            } label: {
                Label {
                    Text("Take Photo")
                        .foregroundStyle(.white)
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
                                .linear(duration: 0.1),
                                value: captureButtonScale
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
    }

    @ViewBuilder
    private func previewButtonsView() -> some View {
        Button("Retake") {
            withAnimation {
                previewImage = nil
            }
        }
        .foregroundStyle(.white)

        Spacer()

        Button("Use photo") {
            onComplete(previewImage)
        }
        .foregroundStyle(.white)
    }
}
