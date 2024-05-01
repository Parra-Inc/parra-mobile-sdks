//
//  CameraView.swift
//  Parra
//
//  Created by Mick MacCallum on 4/26/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct CameraView: View {
    // MARK: - Internal

    var body: some View {
        GeometryReader { geometry in
            ViewfinderView(image: $model.viewfinderImage)
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
                        .frame(
                            height: geometry.size.height * Self
                                .barHeightFactor
                        )
                        .background(.black.opacity(0.75))
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
        .task {
            await model.camera.start()
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

    // MARK: - Private

    private static let barHeightFactor = 0.15

    @StateObject private var model = CameraDataModel()

    private func buttonsView() -> some View {
        HStack(spacing: 60) {
            Spacer()

//            NavigationLink {
//                PhotoCollectionView(photoCollection: model.photoCollection)
//                    .onAppear {
//                        model.camera.isPreviewPaused = true
//                    }
//                    .onDisappear {
//                        model.camera.isPreviewPaused = false
//                    }
//            } label: {
//                Label {
//                    Text("Gallery")
//                } icon: {
//                    ThumbnailView(image: model.thumbnailImage)
//                }
//            }

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
                    }
                }
            }

            HStack {
                Button {
                    model.camera.switchCaptureDevice()
                } label: {
                    Label(
                        "Switch Camera",
                        systemImage: "arrow.triangle.2.circlepath"
                    )
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .padding()
    }
}
