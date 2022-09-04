import UIKit

protocol PermissionsPresentationLogic {
    func presentLoadGreeting(_ response: Permissions.LoadGreeting.Response)
}

protocol PermissionsPresenter: PermissionsPresentationLogic {
    var displayLogic: PermissionsDisplayLogic! { get set }
}

class DefaultPermissionsPresenter: PermissionsPresenter {
    weak var displayLogic: PermissionsDisplayLogic!
}

// MARK: - Presentation Logic
extension DefaultPermissionsPresenter {
    // MARK: - Load Greeting
    func presentLoadGreeting(_ response: Permissions.LoadGreeting.Response) {
        let viewModel: Permissions.LoadGreeting.ViewModel
        if let error = response.error {
            viewModel = .error(error)
        } else if response.isLoading {
            viewModel = .loading
        } else if let name = response.name {
            viewModel = .greeting("Hello \(name)!")
        } else {
            viewModel = .error(NSError(domain: "", code: 0))
        }
        DispatchQueue.main.async { [weak self] in
            self?.displayLogic.displayLoadGreeting(viewModel)
        }
    }
}
