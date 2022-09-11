import Combine
import Foundation

protocol MainBusinessLogic {
    func requestCameraAuthorization()
    func updateRenderingStatus(enabled: Bool)
    func toggleSmoothing(enabled: Bool)
    func toggleTorch(enabled: Bool)
    func updateTorchLevel(levelStatus: TorchBrightness)
}

protocol MainInteractor: MainBusinessLogic {
    var presenter: MainPresentationLogic! { get set }
}

class DefaultMainInteractor: MainInteractor {
    private var cancelBag = Set<AnyCancellable>()
    private let worker: MainWorker
    var presenter: MainPresentationLogic!

    // MARK: - Methods
    init(worker: MainWorker) {
        self.worker = worker
    }
}

extension DefaultMainInteractor {
    // MARK: - Request Camera Authorization
    func requestCameraAuthorization() {
        worker.requestCameraAuthorization()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        ()
                    case let .failure(error):
                        print(error)
                        self?.presenter.presentLoadVideoFeed(Main.LoadData.Response(
                            isCameraEnabled: false,
                            pixelBuffer: nil,
                            error: error
                        ))
                    }
                },
                receiveValue: { [weak self] authorizationStatus in
                    guard authorizationStatus == .authorized else {
                        self?.presenter.presentLoadVideoFeed(Main.LoadData.Response(
                            isCameraEnabled: false,
                            pixelBuffer: nil,
                            error: nil
                        ))
                        return
                    }
                    self?.configureSession()
                }
            )
            .store(in: &cancelBag)
    }
    
    // MARK: - Configure Video Session
    func configureSession() {
        worker.configureSession()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        ()
                    case let .failure(error):
                        print(error)
                        self?.presenter.presentLoadVideoFeed(Main.LoadData.Response(
                            isCameraEnabled: false,
                            pixelBuffer: nil,
                            error: error
                        ))
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.setupPixelBufferListener()
                }
            )
            .store(in: &cancelBag)
    }
    
    // MARK: - Toggle Smoothing
    func toggleSmoothing(enabled: Bool) {
        worker.toggleSmoothing(enabled: enabled)
    }
    
    // MARK: - Toggle Torch
    func toggleTorch(enabled: Bool) {
        worker.toggleTorch(enabled: enabled)
    }
    
    // MARK: - Update Rendering Status
    func updateRenderingStatus(enabled: Bool) {
        worker.updateRenderingStatus(enabled: enabled)
    }
    
    // MARK: - Update Torch Brightness
    func updateTorchLevel(levelStatus: TorchBrightness) {
        worker.updateTorch(with: levelStatus)
    }
    
    // MARK: - Setup Pixel Buffer Listener
    func setupPixelBufferListener() {
        worker.jetPixelBufferUpdate
            .sink(
                receiveValue: { [weak self] pixelBuffer in
                    self?.presenter.presentLoadVideoFeed(Main.LoadData.Response(
                        isCameraEnabled: true,
                        pixelBuffer: pixelBuffer,
                        error: nil
                    ))
                }
            )
            .store(in: &cancelBag)
    }
}
