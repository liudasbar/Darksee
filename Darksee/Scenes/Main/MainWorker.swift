import Foundation
import Combine
import MetalKit
import AVFoundation

protocol MainWorker {
    func requestCameraAuthorization() -> Future<AVAuthorizationStatus, CustomError>
    func configureSession() -> AnyPublisher<Void, CustomError>
    func updateRenderingStatus(enabled: Bool)
    func toggleSmoothing(enabled: Bool)
    func toggleTorch(enabled: Bool, level: Float)
    func updateScreenBrightnessLevel(level: CGFloat)
    var jetPixelBufferUpdate: PassthroughSubject<CVPixelBuffer, Never> { get }
}

class DefaultMainWorker: NSObject, MainWorker, AVCaptureDataOutputSynchronizerDelegate {
    // MARK: - Variables
    private let session = AVCaptureSession()
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(
        deviceTypes: [.builtInLiDARDepthCamera],
        mediaType: .video,
        position: .back
    )
    private var defaultVideoDevice: AVCaptureDevice!
    private var videoDeviceInput: AVCaptureDeviceInput!
    private let depthDataOutput = AVCaptureDepthDataOutput()
    private var outputSynchronizer: AVCaptureDataOutputSynchronizer?
    private let videoDepthConverter = DepthToJETConverter()
    private let dataOutputQueue = DispatchQueue(
        label: "videoDataQueue",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem
    )
    private let sessionQueue = DispatchQueue(label: "sessionQueue", attributes: [], autoreleaseFrequency: .workItem)
    private var renderingEnabled: Bool = true
    var jetPixelBufferUpdate = PassthroughSubject<CVPixelBuffer, Never>()
    
    // MARK: - Update Rendering Status
    func updateRenderingStatus(enabled: Bool) {
        renderingEnabled = enabled
    }
    
    // MARK: - Manage Camera Authorization
    func requestCameraAuthorization() -> Future<AVAuthorizationStatus, CustomError> {
        return Future() { [weak self] promise in
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                promise(.success(.authorized))
            case .notDetermined:
                self?.sessionQueue.suspend()
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    guard granted else {
                        promise(.success(.denied))
                        return
                    }
                    promise(.success(.authorized))
                    self?.sessionQueue.resume()
                }
            case .denied:
                promise(.success(.denied))
            case .restricted:
                promise(.success(.restricted))
            @unknown default:
                promise(.failure(.failedToDetermineCameraAccessStatus))
            }
        }
    }
    
    // MARK: - Session Management
    func configureSession() -> AnyPublisher<Void, CustomError> {
        defaultVideoDevice = videoDeviceDiscoverySession.devices.first
        
        guard let videoDevice = defaultVideoDevice else {
            return .fail(.failedToFindVideoDevice)
        }
        
        do {
            videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
        } catch {
            return .fail(.couldNotCreateVideoDeviceInput)
        }
        
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.vga640x480
        
        // Add video input
        guard session.canAddInput(videoDeviceInput) else {
            session.commitConfiguration()
            return .fail(.couldNotAddVideoDeviceInputToSession)
        }
        session.addInput(videoDeviceInput)
        
        // Add a depth data output
        if session.canAddOutput(depthDataOutput) {
            session.addOutput(depthDataOutput)
            if let connection = depthDataOutput.connection(with: .depthData) {
                connection.isEnabled = true
            } else {
                return .fail(.noAVCaptureSession)
            }
        } else {
            session.commitConfiguration()
            return .fail(.couldNotAddDepthDataOutputToSession)
        }
        
        // Search for highest resolution with half-point depth values
        let depthFormats = videoDevice.activeFormat.supportedDepthDataFormats
        let filtered = depthFormats.filter({
            CMFormatDescriptionGetMediaSubType($0.formatDescription) == kCVPixelFormatType_DepthFloat16
        })
        let selectedFormat = filtered.max(by: {
            first, second in CMVideoFormatDescriptionGetDimensions(first.formatDescription).width < CMVideoFormatDescriptionGetDimensions(second.formatDescription).width
        })
        
        do {
            try videoDevice.lockForConfiguration()
            videoDevice.activeDepthDataFormat = selectedFormat
            videoDevice.unlockForConfiguration()
        } catch {
            session.commitConfiguration()
            return .fail(.couldNotLockDeviceForConfiguration)
        }

        outputSynchronizer = AVCaptureDataOutputSynchronizer(dataOutputs: [depthDataOutput])
        guard let outputSynchronizer = outputSynchronizer else {
            return .fail(.generic)
        }
        outputSynchronizer.setDelegate(self, queue: dataOutputQueue)
        session.commitConfiguration()
        session.startRunning()
        
        toggleSmoothing(enabled: true)
        
        return .just(())
    }
    
    // MARK: - Toggle Smoothing
    func toggleSmoothing(enabled: Bool) {
        sessionQueue.async { [weak self] in
            self?.depthDataOutput.isFilteringEnabled = enabled
        }
    }
    
    // MARK: - Toggle Torch
    func toggleTorch(enabled: Bool, level: Float) {
        guard let device = defaultVideoDevice else {
            return
        }
        guard device.hasTorch else {
            print("Torch isn't available")
            return
        }
        do {
            try device.lockForConfiguration()
            device.torchMode = enabled ? .on : .off
            if enabled {
                try device.setTorchModeOn(level: level)
            }
            device.unlockForConfiguration()
        } catch {
            print("Torch can't be used")
        }
    }
    
    // MARK: - Update Screen Brightness Level
    func updateScreenBrightnessLevel(level: CGFloat) {
        UIScreen.main.brightness = level
    }
}

extension DefaultMainWorker {
    // MARK: - Depth Frame Processing
    func dataOutputSynchronizer(_ synchronizer: AVCaptureDataOutputSynchronizer,
                                didOutput synchronizedDataCollection: AVCaptureSynchronizedDataCollection) {
        guard renderingEnabled else {
            return
        }
        guard renderingEnabled,
            let syncedDepthData: AVCaptureSynchronizedDepthData =
            synchronizedDataCollection.synchronizedData(for: depthDataOutput) as? AVCaptureSynchronizedDepthData else {
                return
        }
        guard !syncedDepthData.depthDataWasDropped else {
            return
        }
        
        let depthData = syncedDepthData.depthData
        let depthPixelBuffer = depthData.depthDataMap
        
        if !videoDepthConverter.isPrepared {
            var depthFormatDescription: CMFormatDescription?
            CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                                         imageBuffer: depthPixelBuffer,
                                                         formatDescriptionOut: &depthFormatDescription)
            videoDepthConverter.prepare(with: depthFormatDescription!, outputRetainedBufferCountHint: 2)
        }
        
        guard let jetPixelBuffer = videoDepthConverter.render(pixelBuffer: depthPixelBuffer) else {
            print("Unable to process depth")
            return
        }
        
        dataOutputQueue.async { [weak self] in
            self?.renderingEnabled = true
        }
        jetPixelBufferUpdate.send(jetPixelBuffer)
    }
}
