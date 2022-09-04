import Foundation

class PermissionsConfigurator {
    class func configure() -> PermissionsViewController {
        let worker = DefaultPermissionsWorker()
        let interactor = DefaultPermissionsInteractor(worker: worker)
        let presenter = DefaultPermissionsPresenter()
        let router = DefaultPermissionsRouter()
        let viewController = PermissionsViewController(interactor: interactor, router: router)
        interactor.presenter = presenter
        presenter.displayLogic = viewController
        router.viewController = viewController
        return viewController
    }
}
