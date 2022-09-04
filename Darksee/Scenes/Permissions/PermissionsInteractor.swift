import Combine
import Foundation

protocol PermissionsBusinessLogic {
    func loadGreeting(_ request: Permissions.LoadGreeting.Request)
}

protocol PermissionsDataStore {
    var userName: String? { get }
}

protocol PermissionsInteractor: PermissionsBusinessLogic, PermissionsDataStore {
    var presenter: PermissionsPresentationLogic! { get set }
}

class DefaultPermissionsInteractor: PermissionsInteractor {
    private var cancelBag = Set<AnyCancellable>()
    private let worker: PermissionsWorker
    var presenter: PermissionsPresentationLogic!
    private(set) var userName: String?

    // MARK: - Methods
    init(worker: PermissionsWorker) {
        self.worker = worker
    }
}

extension DefaultPermissionsInteractor {
    // MARK: - Load Greeting
    func loadGreeting(_ request: Permissions.LoadGreeting.Request) {
        presenter.presentLoadGreeting(Permissions.LoadGreeting.Response(isLoading: true, error: nil, name: nil))
        worker.loadUserName()
            .sink(
                receiveCompletion: { [weak self] in self?.receiveLoadGreetingCompletion($0) },
                receiveValue: { [weak self] in self?.receiveLoadGreetingValue($0) }
            )
            .store(in: &cancelBag)
    }
    
    private func receiveLoadGreetingValue(_ value: String) {
        userName = value
        presenter.presentLoadGreeting(Permissions.LoadGreeting.Response(isLoading: false, error: nil, name: value))
    }
    
    private func receiveLoadGreetingCompletion(_ completion: Subscribers.Completion<Error>) {
        switch completion {
        case .failure(let error):
            presenter.presentLoadGreeting(Permissions.LoadGreeting.Response(isLoading: false, error: error, name: nil))
        case .finished:
            ()
        }
    }
}
