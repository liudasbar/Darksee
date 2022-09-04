import Combine
import Foundation

protocol MainBusinessLogic {
    func requestCameraAuthorization()
    func updateRenderingStatus(enabled: Bool)
}

protocol MainDataStore {
    var userName: String? { get }
}

protocol MainInteractor: MainBusinessLogic, MainDataStore {
    var presenter: MainPresentationLogic! { get set }
}

class DefaultMainInteractor: MainInteractor {
    private var cancelBag = Set<AnyCancellable>()
    private let worker: MainWorker
    var presenter: MainPresentationLogic!
    private(set) var userName: String?

    // MARK: - Methods
    init(worker: MainWorker) {
        self.worker = worker
    }
}

extension DefaultMainInteractor {
    // MARK: - aaaa
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
    
    func updateRenderingStatus(enabled: Bool) {
        worker.updateRenderingStatus(enabled: enabled)
    }
    
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
