import UIKit

protocol MainRoutingLogic {
    var viewController: UIViewController! { get set }

    func routeToError(error: CustomError, dismissable: Bool)
}

protocol MainRouter: MainRoutingLogic { }

class DefaultMainRouter: MainRouter {
    weak var viewController: UIViewController!
}

// MARK: - Routing Logic
extension DefaultMainRouter: MainRoutingLogic {
    // MARK: - Somewhere
    func routeToError(error: CustomError, dismissable: Bool) {
        let targetViewController = ErrorConfigurator.configure(with: error)
        targetViewController.isModalInPresentation = !dismissable
        viewController.present(targetViewController, animated: true)
    }
}
