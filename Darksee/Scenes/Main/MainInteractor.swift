import Combine
import Foundation

protocol MainBusinessLogic {
    func requestCameraAuthorization()
    func updateRenderingStatus(enabled: Bool)
    func toggleSmoothing(enabled: Bool)
    func toggleTorch(enabled: Bool)
    func updateScreenBrightnessLevel(level: ScreenBrightness)
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
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        ()
                    case let .failure(error):
                        print(error)
                    }
                },
                receiveValue: { [weak self] authorizationStatus in
                    guard authorizationStatus == .authorized else {
                        self?.presenter.presentLoadGreeting(Main.LoadGreeting.Response(
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
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        ()
                    case let .failure(error):
                        print(error)
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
        worker.toggleTorch(enabled: enabled, level: 0.1)
    }
    
    // MARK: - Update Rendering Status
    func updateRenderingStatus(enabled: Bool) {
        worker.updateRenderingStatus(enabled: enabled)
    }
    
    // MARK: - Update Screen Brightness
    func updateScreenBrightnessLevel(level: ScreenBrightness) {
        worker.updateScreenBrightnessLevel(
            level: level == .higher ? UIScreen.main.brightness + 0.1 : UIScreen.main.brightness - 0.1
        )
    }
    
    // MARK: - Setup Pixel Buffer Listener
    func setupPixelBufferListener() {
        worker.jetPixelBufferUpdate
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        ()
                    case let .failure(error):
                        print(error)
                    }
                },
                receiveValue: { [weak self] pixelBuffer in
                    self?.presenter.presentLoadGreeting(Main.LoadGreeting.Response(
                        isCameraEnabled: true,
                        pixelBuffer: pixelBuffer,
                        error: nil
                    ))
                }
            )
            .store(in: &cancelBag)
    }
}
