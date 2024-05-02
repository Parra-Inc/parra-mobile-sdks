//
//  Camera.swift
//  Parra
//
//  Created by Mick MacCallum on 4/26/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import AVFoundation
import CoreImage
import UIKit

private let logger = Logger()

class Camera: NSObject {
    // MARK: - Lifecycle

    override init() {
        super.init()
        initialize()
    }

    // MARK: - Internal

    var isPreviewPaused = false

    lazy var previewStream: AsyncStream<CIImage> = AsyncStream { continuation in
        addToPreviewStream = { ciImage in
            if !self.isPreviewPaused {
                continuation.yield(ciImage)
            }
        }
    }

    lazy var photoStream: AsyncStream<AVCapturePhoto> =
        AsyncStream { continuation in
            addToPhotoStream = { photo in
                continuation.yield(photo)
            }
        }

    var isRunning: Bool {
        captureSession.isRunning
    }

    var isUsingFrontCaptureDevice: Bool {
        guard let captureDevice else {
            return false
        }

        return frontCaptureDevices.contains(captureDevice)
    }

    var isUsingBackCaptureDevice: Bool {
        guard let captureDevice else {
            return false
        }

        return backCaptureDevices.contains(captureDevice)
    }

    func start() async {
        let authorized = await checkAuthorization()
        guard authorized else {
            logger.error("Camera access was not authorized.")
            return
        }

        if isCaptureSessionConfigured {
            if !captureSession.isRunning {
                sessionQueue.async { [self] in
                    captureSession.startRunning()
                }
            }

            return
        }

        sessionQueue.async { [self] in
            configureCaptureSession { success in
                guard success else {
                    return
                }
                self.captureSession.startRunning()
            }
        }
    }

    func stop() {
        guard isCaptureSessionConfigured else {
            return
        }

        if captureSession.isRunning {
            sessionQueue.async {
                self.captureSession.stopRunning()
            }
        }
    }

    func switchCaptureDevice() {
        if let captureDevice,
           let index = availableCaptureDevices.firstIndex(of: captureDevice)
        {
            let nextIndex = (index + 1) % availableCaptureDevices.count

            self.captureDevice = availableCaptureDevices[nextIndex]
        } else {
            captureDevice = AVCaptureDevice.default(for: .video)
        }
    }

    func takePhoto(
        flashMode: AVCaptureDevice.FlashMode = .auto
    ) {
        guard let photoOutput else {
            return
        }

        sessionQueue.async {
            var photoSettings = AVCapturePhotoSettings()

            if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                photoSettings =
                    AVCapturePhotoSettings(
                        format: [
                            AVVideoCodecKey: AVVideoCodecType.hevc
                        ]
                    )
            }

            let isFlashAvailable = self.deviceInput?.device
                .isFlashAvailable ?? false

            photoSettings.flashMode = isFlashAvailable ? flashMode : .off

            if let previewPhotoPixelFormatType = photoSettings
                .availablePreviewPhotoPixelFormatTypes.first
            {
                photoSettings
                    .previewPhotoFormat =
                    [
                        kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType
                    ]
            }
            photoSettings.photoQualityPrioritization = .balanced

            if let videoConnection = photoOutput.connection(with: .video) {
                videoConnection.videoRotationAngle = 90.0
            }

            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }

    // MARK: - Private

    private let captureSession = AVCaptureSession()
    private var isCaptureSessionConfigured = false
    private var deviceInput: AVCaptureDeviceInput?
    private var photoOutput: AVCapturePhotoOutput?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var sessionQueue: DispatchQueue!

    private var addToPhotoStream: ((AVCapturePhoto) -> Void)?

    private var addToPreviewStream: ((CIImage) -> Void)?

    private var allCaptureDevices: [AVCaptureDevice] {
        AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInTrueDepthCamera,
                .builtInDualCamera,
                .builtInDualWideCamera,
                .builtInWideAngleCamera,
                .builtInDualWideCamera
            ],
            mediaType: .video,
            position: .unspecified
        ).devices
    }

    private var frontCaptureDevices: [AVCaptureDevice] {
        allCaptureDevices
            .filter { $0.position == .front }
    }

    private var backCaptureDevices: [AVCaptureDevice] {
        allCaptureDevices
            .filter { $0.position == .back }
    }

    private var captureDevices: [AVCaptureDevice] {
        var devices = [AVCaptureDevice]()
        #if os(macOS) || (os(iOS) && targetEnvironment(macCatalyst))
        devices += allCaptureDevices
        #else
        // Front devices first so that the front camera will be chosen by
        // default, if it is available.
        if let frontDevice = frontCaptureDevices.first {
            devices += [frontDevice]
        }

        if let backDevice = backCaptureDevices.first {
            devices += [backDevice]
        }
        #endif
        return devices
    }

    private var availableCaptureDevices: [AVCaptureDevice] {
        captureDevices
            .filter(\.isConnected)
            .filter { !$0.isSuspended }
    }

    private var captureDevice: AVCaptureDevice? {
        didSet {
            guard let captureDevice else {
                return
            }

            logger.debug("Using capture device: \(captureDevice.localizedName)")

            sessionQueue.async {
                self.updateSessionForCaptureDevice(captureDevice)
            }
        }
    }

    private func initialize() {
        sessionQueue = DispatchQueue(label: "session queue")

        captureDevice = availableCaptureDevices.first ?? AVCaptureDevice
            .default(
                for: .video
            )
    }

    private func configureCaptureSession(
        completionHandler: (_ success: Bool) -> Void
    ) {
        var success = false

        captureSession.beginConfiguration()

        defer {
            self.captureSession.commitConfiguration()
            completionHandler(success)
        }

        guard
            let captureDevice,
            let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            logger.error("Failed to obtain video input.")
            return
        }

        let photoOutput = AVCapturePhotoOutput()

        captureSession.sessionPreset = AVCaptureSession.Preset.photo

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(
            self,
            queue: DispatchQueue(label: "VideoDataOutputQueue")
        )

        guard captureSession.canAddInput(deviceInput) else {
            logger.error("Unable to add device input to capture session.")
            return
        }
        guard captureSession.canAddOutput(photoOutput) else {
            logger.error("Unable to add photo output to capture session.")
            return
        }
        guard captureSession.canAddOutput(videoOutput) else {
            logger.error("Unable to add video output to capture session.")
            return
        }

        captureSession.addInput(deviceInput)
        captureSession.addOutput(photoOutput)
        captureSession.addOutput(videoOutput)

        self.deviceInput = deviceInput
        self.photoOutput = photoOutput
        self.videoOutput = videoOutput

        photoOutput.maxPhotoQualityPrioritization = .quality

        updateVideoOutputConnection()

        isCaptureSessionConfigured = true

        success = true
    }

    private func checkAuthorization() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            logger.debug("Camera access authorized.")
            return true
        case .notDetermined:
            logger.debug("Camera access not determined.")
            sessionQueue.suspend()
            let status = await AVCaptureDevice.requestAccess(for: .video)
            sessionQueue.resume()
            return status
        case .denied:
            logger.debug("Camera access denied.")
            return false
        case .restricted:
            logger.debug("Camera library access restricted.")
            return false
        @unknown default:
            return false
        }
    }

    private func deviceInputFor(device: AVCaptureDevice?)
        -> AVCaptureDeviceInput?
    {
        guard let device else {
            return nil
        }

        do {
            return try AVCaptureDeviceInput(device: device)
        } catch {
            logger.error("Error getting capture device input", error)

            return nil
        }
    }

    private func updateSessionForCaptureDevice(
        _ captureDevice: AVCaptureDevice
    ) {
        guard isCaptureSessionConfigured else {
            return
        }

        captureSession.beginConfiguration()

        defer {
            captureSession.commitConfiguration()
        }

        for input in captureSession.inputs {
            if let deviceInput = input as? AVCaptureDeviceInput {
                captureSession.removeInput(deviceInput)
            }
        }

        if let deviceInput = deviceInputFor(device: captureDevice) {
            if !captureSession.inputs.contains(deviceInput),
               captureSession.canAddInput(deviceInput)
            {
                captureSession.addInput(deviceInput)
            }
        }

        updateVideoOutputConnection()
    }

    private func updateVideoOutputConnection() {
        if let videoOutput,
           let videoOutputConnection = videoOutput.connection(with: .video)
        {
            if videoOutputConnection.isVideoMirroringSupported {
                videoOutputConnection
                    .isVideoMirrored = isUsingFrontCaptureDevice
            }
        }
    }
}

// MARK: AVCapturePhotoCaptureDelegate

extension Camera: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error {
            logger.error("Error capturing photo: \(error.localizedDescription)")
            return
        }

        addToPhotoStream?(photo)
    }
}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate

extension Camera: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = sampleBuffer.imageBuffer else {
            return
        }

        connection.videoRotationAngle = 90.0

        addToPreviewStream?(CIImage(cvPixelBuffer: pixelBuffer))
    }
}
