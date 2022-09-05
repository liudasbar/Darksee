import UIKit

enum Main {
    struct LoadData {
        struct Response {
            let isCameraEnabled: Bool
            let pixelBuffer: CVPixelBuffer?
            let error: CustomError?
        }
        enum ViewModel {
            case error(CustomError)
            case data(CVPixelBuffer)
        }
    }
}
