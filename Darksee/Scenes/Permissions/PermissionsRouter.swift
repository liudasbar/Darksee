import UIKit

protocol PermissionsRoutingLogic {
    var viewController: UIViewController! { get set }

    func routeToSomewhere()
}

protocol PermissionsRouter: PermissionsRoutingLogic { }

class DefaultPermissionsRouter: PermissionsRouter {
    weak var viewController: UIViewController!
}

// MARK: - Routing Logic
extension DefaultPermissionsRouter: PermissionsRoutingLogic {
    // MARK: - Somewhere
    func routeToSomewhere() {
        guard let navigationController = viewController.navigationController else {
            return
        }
        let targetViewController = UIViewController()
        targetViewController.view.backgroundColor = .red
        targetViewController.title = "Somewhere"
        navigationController.pushViewController(targetViewController, animated: true)
    }
}
