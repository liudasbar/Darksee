import UIKit

enum Main {
    struct LoadGreeting {
        struct Request {
            let parameter: Bool
        }
        struct Response {
            let isCameraEnabled: Bool
            let pixelBuffer: CVPixelBuffer?
            let error: CustomError?
        }
        enum ViewModel {
            case error(Error)
            case loading
            case greeting(CVPixelBuffer)
        }
    }
}
