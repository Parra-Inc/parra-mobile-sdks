//
//  PhotoCropperView.swift
//  Parra
//
//  Created by Mick MacCallum on 2/22/25.
//

import SwiftUI

enum MaskShape: CaseIterable {
    case circle
    case square
    case rectangle
}

struct PhotoCropperView: View {
    // MARK: - Lifecycle

    init(
        image: UIImage,
        maskShape: MaskShape,
        onComplete: @escaping (UIImage?) -> Void
    ) {
        self.image = image
        self.maskShape = maskShape
        self.onComplete = onComplete

        _viewModel = StateObject(
            wrappedValue: CropViewModel(
                maskRadius: 130,
                maxMagnificationScale: 4.0,
                maskShape: maskShape,
                rectAspectRatio: 1.0
            )
        )
    }

    // MARK: - Internal

    var body: some View {
        let magnificationGesture = MagnificationGesture()
            .onChanged { value in
                let sensitivity: CGFloat = 0.1
                let scaledValue = (value.magnitude - 1) * sensitivity + 1

                let maxScaleValues = viewModel.calculateMagnificationGestureMaxValues()
                viewModel.scale = min(
                    max(scaledValue * viewModel.lastScale, maxScaleValues.0),
                    maxScaleValues.1
                )

                updateOffset()
            }
            .onEnded { _ in
                viewModel.lastScale = viewModel.scale
                viewModel.lastOffset = viewModel.offset
            }

        let dragGesture = DragGesture()
            .onChanged { value in
                let maxOffsetPoint = viewModel.calculateDragGestureMax()
                let newX = min(
                    max(
                        value.translation.width + viewModel.lastOffset.width,
                        -maxOffsetPoint.x
                    ),
                    maxOffsetPoint.x
                )
                let newY = min(
                    max(
                        value.translation.height + viewModel.lastOffset.height,
                        -maxOffsetPoint.y
                    ),
                    maxOffsetPoint.y
                )
                viewModel.offset = CGSize(width: newX, height: newY)
            }
            .onEnded { _ in
                viewModel.lastOffset = viewModel.offset
            }

        let rotationGesture = RotationGesture()
            .onChanged { value in
                viewModel.angle = viewModel.lastAngle + value
            }
            .onEnded { _ in
                viewModel.lastAngle = viewModel.angle
            }

        VStack {
//            componentFactory.buildLabel(
//                text: ""
//            )
            ////            Text(
            ////                configuration.texts.interactionInstructions ??
            ////                NSLocalizedString("interaction_instructions", tableName: localizableTableName, bundle: .module, comment: "")
            ////            )
            ////            .font(configuration.fonts.interactionInstructions)
            ////            .foregroundColor(configuration.colors.interactionInstructions)
            ////            .padding(.top, 30)
            ////            .zIndex(1)

            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .rotationEffect(viewModel.angle)
                    .scaleEffect(viewModel.scale)
                    .offset(viewModel.offset)
                    .opacity(0.5)
                    .overlay(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    viewModel.updateMaskDimensions(for: geometry.size)
                                }
                        }
                    )

                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .rotationEffect(viewModel.angle)
                    .scaleEffect(viewModel.scale)
                    .offset(viewModel.offset)
                    .mask(
                        MaskShapeView(maskShape: maskShape)
                            .frame(
                                width: viewModel.maskSize.width,
                                height: viewModel.maskSize.height
                            )
                    )

                VStack {
                    Spacer()

                    HStack {
                        Button {
                            onComplete(nil)
                        } label: {
                            componentFactory.buildLabel(
                                text: "Cancel"
                            )
                            .padding()
                        }
                        .padding()

                        Spacer()

                        Button {
                            onComplete(cropImage())
                        } label: {
                            componentFactory.buildLabel(
                                text: "Save"
                            )
                            .padding()
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity, alignment: .bottom)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .simultaneousGesture(magnificationGesture)
            .simultaneousGesture(dragGesture)
            .simultaneousGesture(rotationGesture)
        }
        .background(.black)
    }

    // MARK: - Private

    private struct MaskShapeView: View {
        let maskShape: MaskShape

        var body: some View {
            Group {
                switch maskShape {
                case .circle:
                    Circle()
                case .square, .rectangle:
                    Rectangle()
                }
            }
        }
    }

    @StateObject private var viewModel: CropViewModel

    private let image: UIImage
    private let maskShape: MaskShape
    private let onComplete: (UIImage?) -> Void

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory

    private func updateOffset() {
        let maxOffsetPoint = viewModel.calculateDragGestureMax()
        let newX = min(max(viewModel.offset.width, -maxOffsetPoint.x), maxOffsetPoint.x)
        let newY = min(max(viewModel.offset.height, -maxOffsetPoint.y), maxOffsetPoint.y)
        viewModel.offset = CGSize(width: newX, height: newY)
        viewModel.lastOffset = viewModel.offset
    }

    private func cropImage() -> UIImage? {
        var editedImage: UIImage = image

        if let rotatedImage: UIImage = viewModel.rotate(
            editedImage,
            viewModel.lastAngle
        ) {
            editedImage = rotatedImage
        }

        if maskShape == .rectangle {
            return viewModel.cropToRectangle(editedImage)
        } else {
            return viewModel.cropToSquare(editedImage)
        }
    }
}
