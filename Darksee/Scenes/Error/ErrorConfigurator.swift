import Foundation

class ErrorConfigurator {
    class func configure(with error: CustomError) -> ErrorViewController {
        let viewController = ErrorViewController()
        viewController.updateView(error: error)
        return viewController
    }
}
