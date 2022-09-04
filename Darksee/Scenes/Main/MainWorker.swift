import Foundation
import Combine
import MetalKit
import AVFoundation

protocol MainWorker {
    func requestCameraAuthorization() -> Future<AVAuthorizationStatus, CustomError>
    func configureSession() -> AnyPublisher<Void, CustomError>
    func updateRenderingStatus(enabled: Bool)
    func updateSmoothing(enabled: Bool)
    var jetPixelBufferUpdate: PassthroughSubject<CVPixelBuffer, Never> { get }
}

class DefaultMainWorker: NSObject, MainWorker, AVCaptureDataOutputSynchronizerDelegate {
    private let session = AVCaptureSession()
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInLiDARDepthCamera],
                                                                               mediaType: .video,
                                                                               position: .back)
    private var videoDeviceInput: AVCaptureDeviceInput!
    private let videoDataOutput = AVCaptureVideoDataOutput()
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
    
    func updateRenderingStatus(enabled: Bool) {
        renderingEnabled = enabled
    }
    
    func updateSmoothing(enabled: Bool) {
        sessionQueue.async { [weak self] in
            self?.depthDataOutput.isFilteringEnabled = enabled
        }
    }
    
    func requestCameraAuthorization() -> Future<AVAuthorizationStatus, CustomError> {
        return Future() { [weak self] promise in
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                promise(.success(.authorized))
                //Configure session
            case .notDetermined:
                self?.sessionQueue.suspend()
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    guard granted else {
                        promise(.success(.denied))
                        return
                    }
                    promise(.success(.authorized))
                    self?.sessionQueue.resume()
                    //Configure session
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
        let defaultVideoDevice: AVCaptureDevice? = videoDeviceDiscoverySession.devices.first
        
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
        
        // Add a video data output
        guard session.canAddOutput(videoDataOutput) else {
            print("Could not add video data output to the session")
            session.commitConfiguration()
            return .fail(.generic)
        }
        session.addOutput(videoDataOutput)
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        
        // Add a depth data output
        if session.canAddOutput(depthDataOutput) {
            session.addOutput(depthDataOutput)
            depthDataOutput.isFilteringEnabled = false
            if let connection = depthDataOutput.connection(with: .depthData) {
                connection.isEnabled = true
            } else {
                return .fail(.noAVCaptureSession) // Check if return is needed or its okay without fail
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

        outputSynchronizer = AVCaptureDataOutputSynchronizer(dataOutputs: [videoDataOutput, depthDataOutput])
        guard let outputSynchronizer = outputSynchronizer else {
            return .fail(.generic)
        }
        outputSynchronizer.setDelegate(self, queue: dataOutputQueue)
        session.commitConfiguration()
        session.startRunning()
        
        updateSmoothing(enabled: true)
        
        return .just(())
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
//        guard let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) else {
//            return
//        }
        
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
        
//        if !videoDepthMixer.isPrepared {
//            videoDepthMixer.prepare(with: formatDescription, outputRetainedBufferCountHint: 3)
//        }
        
        dataOutputQueue.async { [weak self] in
            self?.renderingEnabled = true
        }
        jetPixelBufferUpdate.send(jetPixelBuffer)
    }
}
