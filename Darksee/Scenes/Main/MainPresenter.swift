import UIKit

protocol MainPresentationLogic {
    func presentLoadVideoFeed(_ response: Main.LoadData.Response)
}

protocol MainPresenter: MainPresentationLogic {
    var displayLogic: MainDisplayLogic! { get set }
}

class DefaultMainPresenter: MainPresenter {
    weak var displayLogic: MainDisplayLogic!
}

// MARK: - Presentation Logic
extension DefaultMainPresenter {
    // MARK: - Load Video Feed
    func presentLoadVideoFeed(_ response: Main.LoadData.Response) {
        let viewModel: Main.LoadData.ViewModel
        if let error = response.error {
            viewModel = .error(error)
        } else if let pixelBuffer = response.pixelBuffer, response.isCameraEnabled {
            viewModel = .data(pixelBuffer)
        } else {
            viewModel = .error(.generic)
        }
        DispatchQueue.main.async { [weak self] in
            self?.displayLogic.displayVideoFeed(viewModel)
        }
    }
}
